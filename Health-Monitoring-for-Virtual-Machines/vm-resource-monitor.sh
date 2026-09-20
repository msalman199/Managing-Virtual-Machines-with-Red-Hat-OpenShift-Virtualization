#!/bin/bash

echo "=== Virtual Machine Resource Monitor ==="
echo "Timestamp: $(date)"
echo

echo "=== Node Resource Usage ==="
oc adm top nodes
echo

echo "=== VM Pod Resource Usage ==="
oc adm top pods --all-namespaces | grep virt-launcher
echo

echo "=== VM Status ==="
oc get vm --all-namespaces
echo

echo "=== VMI Resource Details ==="
for vmi in $(oc get vmi --all-namespaces -o jsonpath='{.items[*].metadata.name}'); do
    namespace=$(oc get vmi $vmi --all-namespaces -o jsonpath='{.items[0].metadata.namespace}')
    echo "VMI: $vmi (Namespace: $namespace)"
    oc get vmi $vmi -n $namespace -o jsonpath='{.spec.domain.resources}' | jq .
    echo
done

echo "=== Storage Usage ==="
oc get pvc --all-namespaces | grep -E "(vm-|vmi-)"
echo

echo "=== Network Usage ==="
oc get pods --all-namespaces -l kubevirt.io/vm -o wide
