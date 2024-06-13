#!/bin/bash

# Install iperf3
sudo apt-get update
sudo apt-get install -y iperf3

# Script to run iperf3 each 60 seconds
cat <<EOF > iperf.sh
#!/bin/bash

# Infinite loop to run iperf3 every 60 seconds
while true; do
    # Run iperf3 with the random port
    iperf3 -c ${server_ip}

    # Wait for 60 seconds before running iperf3 again
    sleep 60
done
EOF

# Give execute permition
chmod +x iperf.sh
# execute script
./iperf.sh