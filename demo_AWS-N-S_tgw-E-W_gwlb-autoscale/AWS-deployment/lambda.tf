#---------------------------------------------------------------------------
# Create lambda function to add second network interfaces to ASG instances
#---------------------------------------------------------------------------

// Create lambda python code
data "template_file" "lambda_code" {
  template = file("./templates/index.py.tpl")

  vars = {
    region_az1           = var.region["region_az1"]
    subnet-fgsp-az1-mgmt = module.vpc-sec-fgsp.subnet-az1_ids["mgmt"]
    subnet-fgsp-az2-mgmt = module.vpc-sec-fgsp.subnet-az2_ids["mgmt"]
    nsg-vpc-sec-ha       = module.vpc-sec-fgsp.nsg_ids["ha"]
    nsg-vpc-sec-mgmt     = module.vpc-sec-fgsp.nsg_ids["mgmt"]
  }
}

// Create index.py file
resource "local_file" "lambda_file" {
  content  = data.template_file.lambda_code.rendered
  filename = "./templates/index.py"
}

// Create archive file with python script with lambda handler
data "archive_file" "lambda_package" {
  depends_on  = [resource.local_file.lambda_file]
  type        = "zip"
  source_file = "./templates/index.py"
  output_path = "./templates/lambda.zip"
}

// Create lambda function to add second interface
resource "aws_lambda_function" "lambda" {
  function_name    = "${var.prefix}-asg-add-eni"
  filename         = "./templates/lambda.zip"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "index.lambda_handler"
  timeout          = 10
}

// Create SNS topic
resource "aws_sns_topic" "sns-asg-notification" {
  name = "${var.prefix}-sns-asg-notification"
}

// Create lifecycle hook to publish in SNS topic ASG FGT AZ1
resource "aws_autoscaling_lifecycle_hook" "fgt-az1-as_lifecycle_hook" {
  name                   = "${var.prefix}-fgt-az1-asg-payg-lifecycle-hook"
  autoscaling_group_name = aws_autoscaling_group.fgt_az1_asg-payg.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"

  notification_target_arn = aws_sns_topic.sns-asg-notification.arn
  role_arn                = aws_iam_role.asg_role.arn
}

// Create lifecycle hook to publish in SNS topic ASG FGT AZ2
resource "aws_autoscaling_lifecycle_hook" "fgt-az2-as_lifecycle_hook" {
  name                   = "${var.prefix}-fgt-az2-asg-payg-lifecycle-hook"
  autoscaling_group_name = aws_autoscaling_group.fgt_az2_asg-payg.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"

  notification_target_arn = aws_sns_topic.sns-asg-notification.arn
  role_arn                = aws_iam_role.asg_role.arn
}

// Suscribe lambda function to SNS topic
resource "aws_sns_topic_subscription" "sns-asg-notification_subscription" {
  topic_arn = aws_sns_topic.sns-asg-notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}

// Add permisson to SNS topic
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns-asg-notification.arn
}

// Create IAM policy and roles for lambda and ASG
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.prefix}-lambda-asg-add-eni-policy"
  path        = "/"
  description = "Policies for lambda function"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DetachNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:AttachNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:AllocateAddress",
                "ec2:AssociateAddress",
                "ec2:ModifyNetworkInterfaceAttribute",
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DescribeAutoScalingGroups",
                "SNS:Subscribe",
                "SNS:ListSubscriptionsByTopic",
                "SNS:GetTopicAttributes",
                "SNS:Publish"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-lambda-asg-add-eni-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_attach" {
  name       = "${var.prefix}-lambda-asg-add-eni-attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "asg_policy" {
  name        = "${var.prefix}-asg-policy"
  path        = "/"
  description = "Policies for ASG to publish in SNS topic"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "SNS:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "asg_role" {
  name = "${var.prefix}-asg-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "autoscaling.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "asg_role_policy-attach" {
  name       = "${var.prefix}-asg-role-policy-attach"
  roles      = [aws_iam_role.asg_role.name]
  policy_arn = aws_iam_policy.asg_policy.arn
}