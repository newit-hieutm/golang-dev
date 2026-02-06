# Plan 4: CI/CD Pipeline

**Objective**: Automate the deployment process using AWS CodePipeline and CodeDeploy.

## 🏗️ Architecture

This plan deploys:

- **CodeDeploy Application & Deployment Group**: Defines how to deploy the code (Rolling update to the ASG).
- **CodePipeline**:
  - **Source Stage**: Watches the S3 Artifact Bucket for new `.zip` files.
  - **Deploy Stage**: Triggers CodeDeploy to update the ASG.

## 📋 Prerequisites

- **Plan 2 (IAM)**: Requires Service Roles.
- **Plan 3 (App Infra)**: Requires ASG and Target Group.

## 🚀 Execution

Run the following command:

```bash
./aws/deploy-all.sh staging cicd
```

## ✅ Verification

1. **Get Pipeline URL**:

   ```bash
   aws cloudformation describe-stacks \
     --stack-name myapp-staging-cicd \
     --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' \
     --output text
   ```

2. **Trigger Limit Test** (Optional):
   You can manually upload a dummy zip to S3 to see the pipeline start, but the real test comes when you push to GitHub.
