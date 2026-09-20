#!/bin/bash

# VM Cloning Automation Script
# Usage: ./clone-vm.sh <source-vm> <clone-name> <namespace>

set -e

SOURCE_VM=$1
CLONE_NAME=$2
NAMESPACE=${3:-default}

if [ $# -lt 2 ]; then
    echo "Usage: $0 <source-vm> <clone-name> [namespace]"
    exit 1
fi

echo "Starting VM cloning process..."
echo "Source VM: $SOURCE_VM"
echo "Clone Name: $CLONE_NAME"
echo "Namespace: $NAMESPACE"

# Check if source VM exists
if ! oc get vm $SOURCE_VM -n $NAMESPACE &>/dev/null; then
    echo "Error: Source VM $SOURCE_VM not found in namespace $NAMESPACE"
    exit 1
fi

# Export source VM configuration
echo "Exporting source VM configuration..."
oc get vm $SOURCE_VM -n $NAMESPACE -o yaml > /tmp/source-vm.yaml

# Create clone configuration
echo "Creating clone configuration..."
sed "s/$SOURCE_VM/$CLONE_NAME/g" /tmp/source-vm.yaml | \
sed '/resourceVersion:/d' | \
sed '/uid:/d' | \
sed '/creationTimestamp:/d' | \
sed '/generation:/d' > /tmp/clone-vm.yaml

# Create DataVolume for clone
echo "Creating DataVolume for clone..."
cat << EODV > /tmp/clone-dv.yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: ${CLONE_NAME}-rootdisk
  namespace: $NAMESPACE
spec:
  source:
    pvc:
      name: ${SOURCE_VM}-rootdisk
      namespace: $NAMESPACE
  pvc:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 20Gi
    storageClassName: local-path
EODV

# Apply DataVolume
echo "Creating DataVolume..."
oc apply -f /tmp/clone-dv.yaml

# Wait for DataVolume to be ready
echo "Waiting for DataVolume to be ready..."
oc wait --for=condition=Ready dv/${CLONE_NAME}-rootdisk -n $NAMESPACE --timeout=300s

# Create cloned VM
echo "Creating cloned VM..."
oc apply -f /tmp/clone-vm.yaml

# Verify clone creation
echo "Verifying clone creation..."
oc get vm $CLONE_NAME -n $NAMESPACE

echo "VM cloning completed successfully!"
echo "Clone VM: $CLONE_NAME"
echo "To start the VM, run: virtctl start $CLONE_NAME -n $NAMESPACE"

# Cleanup temporary files
rm -f /tmp/source-vm.yaml /tmp/clone-vm.yaml /tmp/clone-dv.yaml
