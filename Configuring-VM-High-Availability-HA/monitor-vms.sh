#!/bin/bash
echo "Monitoring VM status - Press Ctrl+C to stop"
while true; do
    clear
    echo "=== VM Status at $(date) ==="
    oc get vmi -o wide
    echo ""
    echo "=== Node Status ==="
    oc get nodes
    sleep 5
done
