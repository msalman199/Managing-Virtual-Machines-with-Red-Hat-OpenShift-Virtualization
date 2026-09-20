#!/bin/bash

# Set environment variables for OpenShift CLI
export KUBECONFIG=/path/to/your/kubeconfig
export PATH=$PATH:/usr/local/bin

# Change to script directory
cd /home/cloud-user

# Execute the snapshot automation script
./snapshot-automation.sh >> /var/log/vm-snapshots.log 2>&1
