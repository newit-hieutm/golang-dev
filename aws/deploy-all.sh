#!/bin/bash
set -e

# Configuration
APP_NAME="myapp"
ENVIRONMENT=${1:-staging} # Default to staging if not provided
REGION="us-east-1"
KEY_NAME="${APP_NAME}-key"

echo "==========================================="
echo "Deploying ${APP_NAME} to ${ENVIRONMENT} in ${REGION}"
echo "==========================================="

# Create Key Pair if it doesn't exist (One manual step handled by script)
if ! aws ec2 describe-key-pairs --key-names "${KEY_NAME}" --region "${REGION}" >/dev/null 2>&1; then
    echo "Creating EC2 Key Pair: ${KEY_NAME}..."
    aws ec2 create-key-pair \
        --key-name "${KEY_NAME}" \
        --query 'KeyMaterial' \
        --output text > "${KEY_NAME}.pem"
    chmod 400 "${KEY_NAME}.pem"
    echo "Key pair created and saved to ${KEY_NAME}.pem"
else
    echo "Key Pair ${KEY_NAME} already exists."
fi

# Function to deploy a stack
deploy_stack() {
    STACK_NAME=$1
    TEMPLATE_FILE=$2
    PARAMS=$3
    
    echo "Deploying stack: ${STACK_NAME}..."
    aws cloudformation deploy \
        --template-file "${TEMPLATE_FILE}" \
        --stack-name "${STACK_NAME}" \
        --parameter-overrides ${PARAMS} \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "${REGION}"
    
    if [ $? -eq 0 ]; then
        echo "✅ Stack ${STACK_NAME} deployed successfully."
    else
        echo "❌ Failed to deploy stack ${STACK_NAME}."
        exit 1
    fi
}


# Usage: ./aws/deploy-all.sh [environment] [plan]
# Example: ./aws/deploy-all.sh staging network

TARGET_PLAN=${2:-all}

# Function to run verification
verify_stack() {
    echo "Verifying stack $1..."
    aws cloudformation describe-stacks --stack-name "$1" --region "${REGION}" --query 'Stacks[0].StackStatus' --output text
}

case "$TARGET_PLAN" in
    "network"|"all")
        deploy_stack "${APP_NAME}-${ENVIRONMENT}-network" \
            "aws/cloudformation/1-network.yml" \
            "Environment=${ENVIRONMENT}"
        ;;
esac

case "$TARGET_PLAN" in
    "iam"|"all")
        deploy_stack "${APP_NAME}-${ENVIRONMENT}-iam-storage" \
            "aws/cloudformation/2-iam-storage.yml" \
            "ApplicationName=${APP_NAME} Environment=${ENVIRONMENT}"
        ;;
esac

case "$TARGET_PLAN" in
    "app"|"all")
        deploy_stack "${APP_NAME}-${ENVIRONMENT}-app-infra" \
            "aws/cloudformation/3-app-infra.yml" \
            "ApplicationName=${APP_NAME} Environment=${ENVIRONMENT} KeyName=${KEY_NAME} MinSize=1 MaxSize=2 DesiredCapacity=1"
        ;;
esac

case "$TARGET_PLAN" in
    "cicd"|"all")
        deploy_stack "${APP_NAME}-${ENVIRONMENT}-cicd" \
            "aws/cloudformation/4-cicd.yml" \
            "ApplicationName=${APP_NAME} Environment=${ENVIRONMENT}"
        ;;
esac

case "$TARGET_PLAN" in
    "observability"|"all")
        deploy_stack "${APP_NAME}-${ENVIRONMENT}-observability" \
            "aws/cloudformation/5-observability.yml" \
            "ApplicationName=${APP_NAME} Environment=${ENVIRONMENT}"
        ;;
esac

echo "==========================================="
echo "🎉 Deployment Completed Successfully!"
echo "==========================================="

# Display Key Outputs
echo "Retrieving key outputs..."
ALB_DNS=$(aws cloudformation describe-stacks --stack-name "${APP_NAME}-${ENVIRONMENT}-app-infra" --region "${REGION}" --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' --output text)
PIPELINE_URL=$(aws cloudformation describe-stacks --stack-name "${APP_NAME}-${ENVIRONMENT}-cicd" --region "${REGION}" --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' --output text)

echo "🌍 Application URL: http://${ALB_DNS}"
echo "🚀 Pipeline URL: ${PIPELINE_URL}"
