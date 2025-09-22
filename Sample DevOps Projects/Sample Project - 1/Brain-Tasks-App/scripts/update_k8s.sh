#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
REPO_NAME=brain-tasks-app
IMAGE_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest

echo "Updating k8s deployment with image $IMAGE_URI"

kubectl set image deployment/brain-tasks-app brain-tasks-app=$IMAGE_URI --record
kubectl rollout status deployment/brain-tasks-app