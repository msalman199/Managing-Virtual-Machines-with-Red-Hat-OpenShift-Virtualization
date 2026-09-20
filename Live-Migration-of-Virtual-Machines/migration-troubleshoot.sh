#!/bin/bash

echo "Live Migration Troubleshooting Checklist"
echo "========================================"

echo "1. Checking OpenShift Virtualization status..."
oc get csv -n openshift-cnv | grep kubevirt

echo -e "\n2. Checking HyperConverged configuration..."
oc get hyperconverged -n openshift-cnv -o yaml | grep -A 10 liveMigration

echo -e "\n3. Checking node readiness..."
oc get nodes -o wide

echo -e "\n4. Checking storage classes..."
oc get storageclass

echo -e "\n5. Checking current migrations..."
oc get vmim -A

echo -e "\n6. Checking recent events..."
oc get events --sort-by='.lastTimestamp' | tail -10

echo -e "\n7. Checking VM instances..."
oc get vmi -A

echo -e "\nTroubleshooting complete!"
