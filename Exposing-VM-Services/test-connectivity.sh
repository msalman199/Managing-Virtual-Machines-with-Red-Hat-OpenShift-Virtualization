#!/bin/bash

echo "=== VM Service Connectivity Test ==="
echo

# Test ClusterIP (internal)
echo "1. Testing ClusterIP Service:"
CLUSTER_IP=$(oc get svc web-server-clusterip -o jsonpath='{.spec.clusterIP}')
echo "   ClusterIP: $CLUSTER_IP"
oc run test-internal --image=curlimages/curl --rm -it --restart=Never -- curl -s http://$CLUSTER_IP | head -1
echo

# Test NodePort
echo "2. Testing NodePort Service:"
NODE_IP=$(oc get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(oc get svc web-server-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
echo "   NodePort URL: http://$NODE_IP:$NODE_PORT"
curl -s http://$NODE_IP:$NODE_PORT | head -1
echo

# Test HTTP Route
echo "3. Testing HTTP Route:"
HTTP_ROUTE=$(oc get route web-server-route -o jsonpath='{.spec.host}')
echo "   Route URL: http://$HTTP_ROUTE"
curl -s http://$HTTP_ROUTE | head -1
echo

# Test HTTPS Route
echo "4. Testing HTTPS Route:"
HTTPS_ROUTE=$(oc get route web-server-https-route -o jsonpath='{.spec.host}')
echo "   HTTPS Route URL: https://$HTTPS_ROUTE"
curl -k -s https://$HTTPS_ROUTE | head -1
echo

echo "=== Test Complete ==="
