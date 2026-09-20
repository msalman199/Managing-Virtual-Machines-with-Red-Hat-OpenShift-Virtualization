#!/bin/bash

echo "=== VM Snapshot Status Report ==="
echo "Generated on: $(date)"
echo

echo "=== All Snapshots ==="
oc get vmsnapshot -n default -o wide

echo
echo "=== Automated Snapshots ==="
oc get vmsnapshot -n default -l automated=true -o wide

echo
echo "=== Recent CronJob Executions ==="
oc get jobs -n default | grep vm-snapshot

echo
echo "=== Storage Usage ==="
oc get volumesnapshot -n default

echo "=== End of Report ==="
