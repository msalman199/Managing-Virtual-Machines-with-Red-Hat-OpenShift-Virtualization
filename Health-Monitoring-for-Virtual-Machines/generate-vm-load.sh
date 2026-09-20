#!/bin/bash

VM_NAME="monitoring-test-vm"
echo "Generating load on VM: $VM_NAME"

# Create a pod that will stress the VM
cat << YAML | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: vm-load-generator
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        cpu: 500m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 512Mi
YAML

echo "Load generator started. Monitor alerts in Prometheus/AlertManager."
