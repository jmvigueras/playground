#! /bin/bash
apt-get update
apt-get install apache2 -y
apt-get install -y iperf iperf3 curl netcat
# Retrieve instance name and IP address from Azure metadata service
NAME=$(curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")
IP=$(curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
# Create index.html file with instance name and IP address
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
    <center>
    <h1><span style="color:Red">Fortinet</span> - GCP Linux VM</h1>
    <p></p>
    <hr/>
    <h2>EC2 Instance Name: $NAME</h2>
    <h2>EC2 Instance IP: $IP</h2>
    </center>
</body>
</html>
EOF