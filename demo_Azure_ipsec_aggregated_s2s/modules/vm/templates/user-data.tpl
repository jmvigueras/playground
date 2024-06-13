#! /bin/bash
apt-get update
apt-get -y install apache2
apt-get -y install iperf3 curl netcat
# Retrieve instance name and IP address from Azure metadata service
INSTANCE_NAME=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2021-02-01&format=text")
INSTANCE_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2021-02-01&format=text")
# Create index.html file with instance name and IP address
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
    <center>
    <h1><span style="color:Red">Fortinet</span> - Azure Linux VM</h1>
    <p></p>
    <hr/>
    <h2>EC2 Instance Name: $INSTANCE_NAME</h2>
    <h2>EC2 Instance IP: $INSTANCE_IP</h2>
    </center>
</body>
</html>
EOF