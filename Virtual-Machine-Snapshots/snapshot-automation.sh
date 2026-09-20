#!/bin/bash

# VM Snapshot Automation Script
# This script creates snapshots of specified VMs with timestamp

# Configuration
NAMESPACE="default"
VM_NAME="test-vm"
SNAPSHOT_PREFIX="auto-snapshot"
MAX_SNAPSHOTS=5

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to create snapshot
create_snapshot() {
    local vm_name=$1
    local snapshot_name="${SNAPSHOT_PREFIX}-${vm_name}-$(date +%Y%m%d-%H%M%S)"
    
    log_message "Creating snapshot: $snapshot_name for VM: $vm_name"
    
    cat > /tmp/snapshot-${snapshot_name}.yaml << EOL
apiVersion: snapshot.kubevirt.io/v1beta1
kind: VirtualMachineSnapshot
metadata:
  name: ${snapshot_name}
  namespace: ${NAMESPACE}
  labels:
    automated: "true"
    vm-name: "${vm_name}"
spec:
  source:
    apiVersion: kubevirt.io/v1
    kind: VirtualMachine
    name: ${vm_name}
EOL

    # Apply the snapshot
    if oc apply -f /tmp/snapshot-${snapshot_name}.yaml; then
        log_message "Snapshot creation initiated successfully: $snapshot_name"
        rm -f /tmp/snapshot-${snapshot_name}.yaml
        return 0
    else
        log_message "ERROR: Failed to create snapshot: $snapshot_name"
        return 1
    fi
}

# Function to cleanup old snapshots
cleanup_old_snapshots() {
    local vm_name=$1
    
    log_message "Cleaning up old snapshots for VM: $vm_name"
    
    # Get snapshots sorted by creation time (oldest first)
    local snapshots=$(oc get vmsnapshot -n $NAMESPACE \
        -l automated=true,vm-name=$vm_name \
        --sort-by=.metadata.creationTimestamp \
        -o jsonpath='{.items[*].metadata.name}')
    
    local snapshot_array=($snapshots)
    local snapshot_count=${#snapshot_array[@]}
    
    if [ $snapshot_count -gt $MAX_SNAPSHOTS ]; then
        local snapshots_to_delete=$((snapshot_count - MAX_SNAPSHOTS))
        log_message "Found $snapshot_count snapshots, deleting oldest $snapshots_to_delete"
        
        for ((i=0; i<snapshots_to_delete; i++)); do
            local snapshot_to_delete=${snapshot_array[$i]}
            log_message "Deleting old snapshot: $snapshot_to_delete"
            oc delete vmsnapshot $snapshot_to_delete -n $NAMESPACE
        done
    else
        log_message "Snapshot count ($snapshot_count) is within limit ($MAX_SNAPSHOTS)"
    fi
}

# Main execution
main() {
    log_message "Starting automated snapshot process"
    
    # Check if VM exists
    if ! oc get vm $VM_NAME -n $NAMESPACE >/dev/null 2>&1; then
        log_message "ERROR: VM $VM_NAME not found in namespace $NAMESPACE"
        exit 1
    fi
    
    # Create snapshot
    if create_snapshot $VM_NAME; then
        # Wait a moment for snapshot to be registered
        sleep 10
        
        # Cleanup old snapshots
        cleanup_old_snapshots $VM_NAME
        
        log_message "Automated snapshot process completed successfully"
    else
        log_message "ERROR: Automated snapshot process failed"
        exit 1
    fi
}

# Execute main function
main "$@"
