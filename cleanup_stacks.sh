#!/bin/bash
set -e

BUCKET1="myapp-staging-artifacts-332809474715"
BUCKET2="myapp-staging-pipeline-332809474715"

echo "Emptying S3 buckets..."
aws s3 rm s3://$BUCKET1 --recursive || echo "Bucket $BUCKET1 not found or empty"
aws s3 rm s3://$BUCKET2 --recursive || echo "Bucket $BUCKET2 not found or empty"

# Delete stacks in reverse order
STACKS=("myapp-staging-observability" "myapp-staging-cicd" "myapp-staging-app-infra" "myapp-staging-iam-storage" "myapp-staging-network")

for stack in "${STACKS[@]}"; do
    echo "Deleting stack: $stack"
    aws cloudformation delete-stack --stack-name "$stack"
    echo "Waiting for stack $stack to be deleted..."
    aws cloudformation wait stack-delete-complete --stack-name "$stack"
    echo "Stack $stack deleted."
done

echo "All stacks deleted successfully."
