#!/bin/bash

# Batch VM Cloning Script
# Usage: ./batch-clone.sh <source-vm> <clone-prefix> <count> [namespace]

set -e

SOURCE_VM=$1
CLONE_PREFIX=$2
COUNT=$3
NAMESPACE=${4:-default}

if [ $# -lt 3 ]; then
    echo "Usage: $0 <source-vm> <clone-prefix> <count> [namespace]"
    exit 1
fi

echo "Starting batch VM cloning process..."
echo "Source VM: $SOURCE_VM"
echo "Clone Prefix: $CLONE_PREFIX"
echo "Count: $COUNT"
echo "Namespace: $NAMESPACE"

for i in $(seq 1 $COUNT); do
    CLONE_NAME="${CLONE_PREFIX}-${i}"
    echo "Creating clone $i of $COUNT: $CLONE_NAME"
    
    ./clone-vm.sh $SOURCE_VM $CLONE_NAME $NAMESPACE
    
    echo "Clone $CLONE_NAME created successfully"
    echo "---"
done

echo "Batch cloning completed!"
echo "Created $COUNT clones with prefix: $CLONE_PREFIX"
