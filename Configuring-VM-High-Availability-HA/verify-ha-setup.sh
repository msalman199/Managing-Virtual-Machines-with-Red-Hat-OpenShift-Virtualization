#!/bin/bash

echo "=== High Availability Verification ==="
echo ""

echo "1. Checking node status and taints:"
oc get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,TAINTS:.spec.taints

echo ""
echo "2. Checking VM distribution across nodes:"
oc get vmi -o custom-columns=NAME:.metadata.name,NODE:.status.nodeName,PHASE:.status.phase

echo ""
echo "3. Checking affinity and anti-affinity rules:"
oc get vmi -o yaml | grep -A 10 -B 2 affinity

echo ""
echo "4. Checking eviction strategies:"
oc get vmi -o custom-columns=NAME:.metadata.name,EVICTION:.spec.evictionStrategy

echo ""
echo "5. Testing node drain simulation:"
# This would be run interactively
echo "Run: oc adm drain <node-name> --ignore-daemonsets --delete-emptydir-data --force"

echo ""
echo "=== HA Verification Complete ==="
