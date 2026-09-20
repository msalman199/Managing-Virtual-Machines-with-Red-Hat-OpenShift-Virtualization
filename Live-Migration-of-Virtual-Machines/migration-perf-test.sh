#!/bin/bash

VM_NAME="perf-test-vm"
RESULTS_FILE="migration-results.txt"

echo "Migration Performance Test Results" > $RESULTS_FILE
echo "=================================" >> $RESULTS_FILE
echo "Test Date: $(date)" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Function to create test VM
create_test_vm() {
    local vm_name=$1
    local memory_size=$2
    
    cat << EOF | oc apply -f -
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: ${vm_name}
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/vm: ${vm_name}
    spec:
      domain:
        cpu:
          cores: 2
        devices:
          disks:
          - disk:
              bus: virtio
            name: containerdisk
        resources:
          requests:
            memory: ${memory_size}
      volumes:
      - containerDisk:
          image: quay.io/kubevirt/fedora-cloud-container-disk-demo
        name: containerdisk
