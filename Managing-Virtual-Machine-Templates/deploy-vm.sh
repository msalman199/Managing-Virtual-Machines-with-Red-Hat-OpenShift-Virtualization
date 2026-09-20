#!/bin/bash

# Load configuration
source vm-configs.env

TEMPLATE_NAME=$1
VM_NAME=$2
ENVIRONMENT=$3

if [ -z "$TEMPLATE_NAME" ] || [ -z "$VM_NAME" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <template-name> <vm-name> <environment>"
    echo "Environments: dev, test, prod"
    exit 1
fi

# Set SSH public key
SSH_PUB_KEY="$(cat ~/.ssh/vm-lab-key.pub)"

case $ENVIRONMENT in
    "dev")
        oc process $TEMPLATE_NAME \
          -p VM_NAME=$VM_NAME \
          -p CPU_CORES=$DEV_CPU_CORES \
          -p MEMORY=$DEV_MEMORY \
          -p PROJECTS_DISK_SIZE=$DEV_PROJECTS_DISK \
          -p SSH_PUBLIC_KEY="$SSH_PUB_KEY" \
          | oc apply -f -
        ;;
    "test")
        oc process $TEMPLATE_NAME \
          -p VM_NAME=$VM_NAME \
          -p CPU_CORES=$TEST_CPU_CORES \
          -p MEMORY=$TEST_MEMORY \
          -p PROJECTS_DISK_SIZE=$TEST_PROJECTS_DISK \
          -p SSH_PUBLIC_KEY="$SSH_PUB_KEY" \
          | oc apply -f -
        ;;
    "prod")
        oc process production-vm-template \
          -p VM_NAME=$VM_NAME \
          -p CPU_CORES=$PROD_CPU_CORES \
          -p MEMORY=$PROD_MEMORY \
          -p DATA_DISK_SIZE=$PROD_DATA_DISK \
          -p LOGS_DISK_SIZE=$PROD_LOGS_DISK \
          -p SSH_PUBLIC_KEY="$SSH_PUB_KEY" \
          | oc apply -f -
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        exit 1
        ;;
esac

echo "VM $VM_NAME deployed for $ENVIRONMENT environment"
