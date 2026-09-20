#!/bin/bash

# Performance-optimized VM cloning script
SOURCE_VM=$1
CLONE_NAME=$2
NAMESPACE=${3:-default}

# Use smart cloning when possible
cat << EOYAML > /tmp/optimized-clone-dv.yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: ${CLONE_NAME}-rootdisk
  namespace: $NAMESPACE
  annotations:
    cdi.kubevirt.io/storage.clone.token: "true"
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
    volumeMode: Block
EOYAML

oc apply -f /tmp/optimized-clone-dv.yaml
echo "Optimized DataVolume created for faster cloning"
