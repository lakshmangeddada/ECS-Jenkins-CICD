#!/bin/bash
if [ "$0" = "$BASH_SOURCE" ]; then
  echo "This script is meant to be sourced, not executed."
  exit 1
fi

env="dev"
ACCOUNT_NUMBER="123456789012"
REGION="us-west-2"
TARGET_GROUP="dev-logaggresive-TargetGroup-1A2B3C4D5E6F"
SUBNETS="subnet-1a2b3c4d,subnet-5e6f7g8h"
SECURITY_GROUPS="sg-1a2b3c4d,sg-5e6f7g8h"
NAME="dev-logaggresive"
TD_CFT_FILENAME="taskdefinition.yml"
STACK_NAME="dev-logaggtigator-td"
SERVICE_NAME="dev-logaggtigator"
CLUSTER_NAME="dev-logaggtigator"
DOCKER_IMAGE_NAME="dev-logaggtigator"
