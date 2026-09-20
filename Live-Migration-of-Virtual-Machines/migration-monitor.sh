#!/bin/bash

VM_NAME="migration-test-vm"
MIGRATION_NAME=$(oc get vmim -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$MIGRATION_NAME" ]; then
    echo "No active migration found"
    exit 1
fi

echo "Monitoring migration: $MIGRATION_NAME"
echo "=================================="

while oc get vmim $MIGRATION_NAME >/dev/null 2>&1; do
    # Get migration status
    STATUS=$(oc get vmim $MIGRATION_NAME -o jsonpath='{.status.phase}')
    
    # Get VM current node
    CURRENT_NODE=$(oc get vmi $VM_NAME -o jsonpath='{.status.nodeName}')
    
    # Get migration progress if available
    PROGRESS=$(oc get vmim $MIGRATION_NAME -o jsonpath='{.status}' | jq -r '.conditions[]? | select(.type=="Running") | .message' 2>/dev/null || echo "N/A")
    
    echo "$(date): Status=$STATUS, Current Node=$CURRENT_NODE"
    
    sleep 2
done

echo "Migration completed!"
