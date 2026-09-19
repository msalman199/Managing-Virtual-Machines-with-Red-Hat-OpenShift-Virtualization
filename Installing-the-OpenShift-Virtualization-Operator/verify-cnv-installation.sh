#!/bin/bash

echo "=== OpenShift Virtualization Installation Verification ==="
echo

echo "1. Checking namespace..."
oc get namespace openshift-cnv
echo

echo "2. Checking operator installation..."
oc get csv -n openshift-cnv
echo

echo "3. Checking HyperConverged status..."
oc get hyperconverged -n openshift-cnv
echo

echo "4. Checking KubeVirt status..."
oc get kubevirt -n openshift-cnv
echo

echo "5. Checking all pods status..."
oc get pods -n openshift-cnv
echo

echo "6. Checking CRDs..."
oc get crd | grep kubevirt | wc -l
echo "KubeVirt CRDs found"
echo

echo "7. Checking node readiness for virtualization..."
oc get nodes -o wide
echo

echo "=== Verification Complete ==="
