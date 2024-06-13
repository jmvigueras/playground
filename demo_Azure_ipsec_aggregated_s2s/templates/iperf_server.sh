#!/bin/bash

# Install iperf3
sudo apt-get update
sudo apt-get install -y iperf3

# Execute iperf3 server
iperf3 -s &