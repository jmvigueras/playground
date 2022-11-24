#---------------------------------------------------------------------------------------
# Template for Lambda code function to add an interface to ASG instances in other subnet
#
# - Base on https://aws.amazon.com/premiumsupport/knowledge-center/ec2-auto-scaling-multiple-network-interfaces/
# - Updated code to pasrse an autoscaling event from SNS topic
# - Lambda will add new interface to instance and allocated new public IP
# - Check the policy assigned to this lambda to allow those actions
#
# jvigueras@fortinet.com
#---------------------------------------------------------------------------------------

import boto3
import botocore
import sys
from datetime import datetime
import json

ec2_client = boto3.client('ec2')
asg_client = boto3.client('autoscaling')

def lambda_handler(event, context):
    global LifecycleHookName, AutoScalingGroupName, LifecycleActionToken, instance_id, event_asg
    # Parsing autoscaling event when comming from SNS topic
    event_asg = json.loads(event['Records'][0]['Sns']['Message'])
    instance_id = event_asg['EC2InstanceId']
    LifecycleHookName = event_asg['LifecycleHookName']
    AutoScalingGroupName = event_asg['AutoScalingGroupName']
    LifecycleActionToken = event_asg['LifecycleActionToken']
    instance_result = ec2_client.describe_instances(InstanceIds=[instance_id])
    asg_response = asg_client.describe_auto_scaling_groups(
            AutoScalingGroupNames=[event_asg['AutoScalingGroupName']])
    
    if event_asg['Destination'] == "AutoScalingGroup":

        #This function will check if the instance already has multiple ENIs attached.  If a warm pool is configured in the auto scaling group and --instance-reuse-policy ’{“ReuseOnScaleIn”: true} was configured while configuring the warm pool, a second ENI will already be attached to the instance that scaled in to the warm pool
        if check_number_of_interfaces(instance_result) > 1:
            log("The instance {} already has more than one interface attached.".format(instance_id))
            
        # If the instance is launched for the first time into the auto scaling group or from the warm pool(not scaled into warm pool instances), the following step will be executed
        else:

            subnet_id = get_subnet_id(instance_result)
            
            # step 1: create new interface in MGMT subnet 
            if instance_result['Reservations'][0]['Instances'][0]['Placement']['AvailabilityZone'] == "eu-west-1a" :
                interface_id = create_interface("subnet-00b82f09a0f55d1bb")
            else:
                interface_id = create_interface("subnet-03623873dc839d435")
            
            # step 2: attach management ha security groups to new interface
            attachment_sg = attach_securitygroup(interface_id)
            
            # step 3: attach new interface to instance
            attachment = attach_interface(interface_id,instance_id)
            
            # step 4: allocate new pubic IP and to associate to interface
            new_publicip = allocate_publicip()
            attachment_publicip = associate_publicip(new_publicip['AllocationId'],interface_id)

            #Will check for error with network interface attachment. If there is any error, complete lifecycle call is run to terminate the instance        
            if interface_id and not attachment:
                log("Removing network interface {} after attachment failed.".format(interface_id))
                log('{"Error": "1"}')
                delete_interface(interface_id)
                abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
                return

            #Modifying network interface attribute to set DeleteOnTermination as True. This ensures the interface is deleted when the instance is terminated, to prevent hitting EC2 quotas
            set_delete_true = ec2_client.modify_network_interface_attribute(
                Attachment={
                    'AttachmentId': attachment,
                    'DeleteOnTermination': True,
                },
                NetworkInterfaceId= interface_id,
            )

            log('{"Exit": "0"}')

    #Attaching of second interface is skipped if the instance is launched into the warm pool to avoid hitting network interfaces limit while the instance is not being used and is in warm pool.
    #This section is run when the instance is launched into a warm pool.
    else:
        log("Instance {} launching in warm pool. No action taken".format(instance_id))
        
    continue_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)   
    

# check_number_of_interfaces function checks the number of interfaces attached to the instances
def check_number_of_interfaces(instance_result):
    interfaces = instance_result['Reservations'][0]['Instances'][0]['NetworkInterfaces']
    return len(interfaces)

# get_subnet_id function checks the subnet id of the instance's first ENI
def get_subnet_id(instance_result):
    try:
        vpc_subnet_id = instance_result['Reservations'][0]['Instances'][0]['SubnetId']
        log("Subnet id: {} for Instance {}".format(vpc_subnet_id,instance_id))

    except botocore.exceptions.ClientError as e:
        log("Error describing the instance {}: {}".format(instance_id, e.response['Error']['Code']))
        vpc_subnet_id = None
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)

    return vpc_subnet_id

# create_interface will create a new interface in the subnet that is not the subnet of the instance's first ENI
def create_interface(subnet_id):
    network_interface_id = None   
    try:
        network_interface = ec2_client.create_network_interface(SubnetId=subnet_id)
        network_interface_id = network_interface['NetworkInterface']['NetworkInterfaceId']
        log("Created network interface: {} for Instance {}".format(network_interface_id,instance_id))

    except botocore.exceptions.ClientError as e:
        log("Error creating network interface: {} for Instance {}".format(e.response['Error']['Code'],instance_id))
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
    return network_interface_id

# attach Security Group to interface
def attach_securitygroup(network_interface_id):
    response = None
    try:
        response = ec2_client.modify_network_interface_attribute(
            Groups=[
                'sg-04d875f72f93ce3ba',
                'sg-08142a0141b489211',
            ],
            NetworkInterfaceId=network_interface_id,
        )
        log("Attached security groups to interface {}".format(network_interface_id))

    except botocore.exceptions.ClientError as e:
        log("Error attaching security group for interface {} error {}".format(network_interface_id,e.response['Error']['Code']))
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
    
    return response

# attach_interface will attach the newly created interface as the second interface
def attach_interface(network_interface_id, instance_id):
    attachment = None
    try:
        attach_interface = ec2_client.attach_network_interface(
            NetworkInterfaceId=network_interface_id,
            InstanceId=instance_id,
            DeviceIndex=1
        )
        attachment = attach_interface['AttachmentId']
        log("Created network attachment: {} for Instance {}".format(attachment,instance_id))
    
    except botocore.exceptions.ClientError as e:
        log("Error attaching network interface {} to Instance {}. Error: {}".format(network_interface_id,instance_id,e.response['Error']['Code']))
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
    
    return attachment

# allocate new public IP
def allocate_publicip():
    response = None
    try:  
        response = ec2_client.allocate_address(
            Domain='vpc',
        )
        log("New IP allocation: {}".format(response['AllocationId']))

    except botocore.exceptions.ClientError as e:
        log("Error allocation new pubic IP error {}".format(e.response['Error']['Code']))
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
        
    return response

# associate new public IP
def associate_publicip(allocation_id,network_interface_id):
    response = None
    try:  
        response = ec2_client.associate_address(
            AllocationId=allocation_id,
            NetworkInterfaceId=network_interface_id,
        )
        log("Finish association public IP allocation {} to interface {}".format(allocation_id,network_interface_id))
    
    except botocore.exceptions.ClientError as e:
        log("Error associate public IP {}".format(e.response['Error']['Code'],network_interface_id))
        abandon_lifecycle_action(LifecycleHookName, AutoScalingGroupName, instance_id, LifecycleActionToken)
    
    return response

# delete_interface is run when there might be an error while attaching the secondary interface
def delete_interface(network_interface_id):
    try:
        ec2_client.delete_network_interface(
            NetworkInterfaceId=network_interface_id
        )
        return True

    except botocore.exceptions.ClientError as e:
        log("Error deleting interface {}: {}".format(network_interface_id, e.response['Error']['Code']))


# Run complete-lifecycle-action call to continue bringing the instance InService        
def continue_lifecycle_action(hookname, groupname, instance_id, tokenname):
    try:
        asg_client.complete_lifecycle_action(
        LifecycleHookName=hookname,
        AutoScalingGroupName=groupname,
        InstanceId=instance_id,
        LifecycleActionToken=tokenname,
        LifecycleActionResult='CONTINUE'
        ) 
        log("Completing Lifecycle hook for instance {} with Result:CONTINUE".format(instance_id))

    except botocore.exceptions.ClientError as e:
        log("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']['Code']))
        log('{"Error": "1"}')
    return

# Run complete-lifecycle-action call to terminate the instance due to an error
def abandon_lifecycle_action(hookname,groupname,instance_id,tokenname):
    try:
        asg_client.complete_lifecycle_action(
        LifecycleHookName=hookname,
        AutoScalingGroupName=groupname,
        InstanceId=instance_id,
        LifecycleActionToken=tokenname,
        LifecycleActionResult='ABANDON'
        ) 
        log("Completing Lifecycle hook for instance {} with Result:ABANDON".format(instance_id))   
    except botocore.exceptions.ClientError as e:
        log("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']['Code']))
        log('{"Error": "1"}')
    return

def log(message):
    print('{}Z {}'.format(datetime.utcnow().isoformat(), message))