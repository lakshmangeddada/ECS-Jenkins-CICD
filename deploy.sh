#!/bin/bash

CURRENT_TIME=$(date +%Y-%m-%d-%H-%M-%S)
export CURRENT_TIME=$CURRENT_TIME

CURRENT_DIR=$(dirname "$0")
REPO_DIR="$CURRENT_DIR/."

if [ "$1" = "dev" ]; then
  source $CURRENT_DIR/dev/deploy-variables.sh
else
    echo "Usage: $0 dev"
    exit 1
fi

#validation of parameter variables.
if [ -z "$ENV" ]; then
  echo "$ENV is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$$DOCKER_IMAGE_NAME" ]; then
  echo "$DOCKER_IMAGE_NAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$ACCOUNT_NUMBER" ]; then
  echo "$ACCOUNT_NUMBER is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "$REGION is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$TARGET_GROUP" ]; then
  echo "$TARGET_GROUP is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$SUBNETS" ]; then
  echo "$SUBNETS is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$SECURITY_GROUPS" ]; then
  echo "$SECURITY_GROUPS is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$NAME" ]; then
  echo "$NAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$TD_CFT_FILENAME" ]; then
  echo "$TD_CFT_FILENAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$STACK_NAME" ]; then
  echo "$STACK_NAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$SERVICE_NAME" ]; then
  echo "$SERVICE_NAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "$CLUSTER_NAME is not set, Please validate deploy-variables.sh"
  exit 1
fi

# If we are dooing jenkins build first login to the ECR
echo "AWS ECR Login"
temp = $(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com)
echo $temp
echo "AWS ECR Login Done"

# Build the docker image
echo "Building Docker Image"
BUILD_COMMAND="docker build --no-cache -t $DOCKER_IMAGE_NAME \
    --build-arg http_proxy=$HTTP_PROXY \
    --build-arg https_proxy=$HTTPS_PROXY \
    --build-arg HHTP_PROXY=$HTTP_PROXY \
    --build-arg HTTPS_PROXY=$HTTPS_PROXY \
    $REPO_DIR"

    echo "Running build command: $BUILD_COMMAND"

    if ! $BUILD_COMMAND; then
        echo "Error, exiting deplo script..."
        exit 1
    fi

# Tag the docker image
TAG_COMMAND="docker tag $DOCKER_IMAGE_NAME:latest $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$NAME:$CURRENT_TIME-$ENV"
echo "Tagging Docker Image"
echo "Running tag command: $TAG_COMMAND"
if ! $TAG_COMMAND; then
    echo "Error, exiting deploy script..."
    exit 1
fi

# Push the docker image
echo "aws login HT account"
login_HT = $(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com)
echo "aws login end HT account"
PUSH_COMMAND="docker push $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$NAME:$CURRENT_TIME-$ENV"
echo "Pushing Docker Image"
echo "Running push command: $PUSH_COMMAND"
if ! $PUSH_COMMAND; then
    echo "Error, exiting deploy script..."
    exit 1
fi

# Deploy the task definition
echo "step 4"
echo "Deploying Task Definition"
DEPLOY_COMMAND="aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file cf-template/$TD_CFT_FILENAME \
    --parameter-overrides \
        Environment=$ENV \
        ImageTag=$CURRENT_TIME-$ENV \
    --region $REGION \
    ls -lah
echo "Running deploy command: $DEPLOY_COMMAND"
if ! $DEPLOY_COMMAND; then
    echo "Error, exiting deploy script..."
    exit 1
fi

TASK_DEFINITION=$(aws cloudformation describe-stacks 
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs[?OutputKey=='TaskDefinitionArn'].OutputValue" --output text \
    --region $REGION)
echo "Task Definition: $TASK_DEFINITION"

# *********Update the service*********
echo "Updating ECS Service with new Task Definition"
UPDATE_SERVICE_COMMAND="aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --network-configuration 'awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUPS],assignPublicIp=DISABLED}' \
    --task-definition $TASK_DEFINITION \
    --force-new-deployment \
    --region $REGION"
echo "Running update service command: $UPDATE_SERVICE_COMMAND"
if ! $UPDATE_SERVICE_COMMAND; then
    echo "Error, exiting deploy script..."
    exit 1
fi



