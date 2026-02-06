# Go Application Deployment to AWS (CloudFormation Optimized)

## GitHub Actions + CodePipeline + CodeDeploy + ALB + ASG

> **Best Practice Deployment Guide**  
> Version: 2.0.0 (CloudFormation Infrastructure as Code)  
> Last Updated: February 2026

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Phase 1: Local Setup](#phase-1-local-setup)
- [Phase 2: AWS Infrastructure (CloudFormation)](#phase-2-aws-infrastructure-cloudformation)
- [Phase 3: GitHub Actions Setup](#phase-3-github-actions-setup)
- [Phase 4: Deployment & Verification](#phase-4-deployment--verification)
- [Phase 5: Monitoring & Maintenance](#phase-5-monitoring--maintenance)
- [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

The architecture remains consistent with best practices but is now fully managed via Infrastructure as Code (IaC) using AWS CloudFormation.

```
┌──────────────────────────────────────────────────────────────────┐
│  INFRASTRUCTURE AS CODE (CloudFormation)                         │
│  ├─ Stack 1: Network (VPC, Subnets)                              │
│  ├─ Stack 2: IAM & Storage (Roles, S3 Buckets)                   │
│  ├─ Stack 3: App Infra (ALB, ASG, EC2)                           │
│  ├─ Stack 4: CI/CD (CodePipeline, CodeDeploy)                    │
│  └─ Stack 5: Observability (Dashboards, Alarms)                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### Required Tools

```bash
# Local development
- Go 1.21+
- Git
- AWS CLI v2
- Make

# AWS Account
- Active AWS account
- IAM user with AdministratorAccess (for running CloudFormation)
- AWS CLI configured locally (`aws configure`)
```

### estimated Costs

```yaml
Monthly Cost Estimate (ap-southeast-1):
  EC2 (t3.micro x2):        ~$12/month
  ALB:                      ~$20/month
  S3:                       ~$1/month
  CodePipeline:             ~$1/month
  Data Transfer:            ~$5/month
  ─────────────────────────────────────
  TOTAL:                    ~$39/month
```

---

## 📁 Project Structure

```
myapp/
├── .github/
│   └── workflows/              # GitHub Actions (CI + CodePipeline Trigger)
├── cmd/
│   └── api/                    # Application Entrypoint
├── deployments/
│   ├── appspec.yml             # CodeDeploy Specification
│   ├── scripts/                # Deployment Hooks (Start/Stop)
│   └── systemd/                # Systemd Service File
├── aws/
│   ├── cloudformation/         # IaC Templates
│   │   ├── 1-network.yml
│   │   ├── 2-iam-storage.yml
│   │   ├── 3-app-infra.yml
│   │   ├── 4-cicd.yml
│   │   └── 5-observability.yml
│   └── deploy-all.sh           # Master Deployment Script
├── go.mod
├── Makefile
└── README.md
```

---

## 🚀 Phase 1: Local Setup

_(Identical to previous guide - ensure your Go app, Makefile, and local tests are working)_

### Key Files Verification

Ensure you have your `cmd/api/main.go` and `Makefile` ready as per the standard Go project layout.

---

## ☁️ Phase 2: AWS Infrastructure (The 5 Plans)

We have broken down the infrastructure setup into **5 Logical Plans**. You can execute them all at once or one by one for better control.

### 📂 Plan Documents

Detailed explanation for each layer:

1. [**Plan 1: Networking**](plans/01_networking.md) - VPC, Subnets, Routes
2. [**Plan 2: Security & Storage**](plans/02_security_and_storage.md) - IAM Roles, S3 Buckets
3. [**Plan 3: Compute Infrastructure**](plans/03_compute_infrastructure.md) - ALB, ASG, Launch Template
4. [**Plan 4: CI/CD Pipeline**](plans/04_cicd_pipeline.md) - CodePipeline, CodeDeploy
5. [**Plan 5: Observability**](plans/05_observability.md) - Dashboards, Alarms

### 🚀 Execution

**Option A: Deploy EVERYTHING (Quick Start)**

```bash
./aws/deploy-all.sh staging all
```

**Option B: Deploy Step-by-Step (Recommended for learning)**

```bash
# 1. Build Network
./aws/deploy-all.sh staging network

# 2. Create IAM Roles & S3
./aws/deploy-all.sh staging iam

# 3. Provision Compute (ALB + ASG)
./aws/deploy-all.sh staging app

# 4. Create Pipeline
./aws/deploy-all.sh staging cicd

# 5. Setup Monitoring
./aws/deploy-all.sh staging observability
```

---

## 🔄 Phase 3: GitHub Actions Setup

Since CloudFormation handled the heavy lifting of creating AWS resources, we just need to configure GitHub Actions to build and push the artifact.

### 3.1 GitHub Secrets

Go to repository **Settings → Secrets and variables → Actions** and add:

- `AWS_ACCESS_KEY_ID`: Your IAM access key.
- `AWS_SECRET_ACCESS_KEY`: Your IAM secret key.
- `AWS_REGION`: `ap-southeast-1`

### 3.2 Workflow Update

Ensure your `.github/workflows/deploy-staging.yml` looks like this. Note that we dynamicallly retrieve the bucket name or use the standard naming convention defined in our CloudFormation templates.

**Important**: The CloudFormation template generates bucket names with the Account ID to ensure uniqueness. You might want to update the workflow to hardcode the bucket name if you customized it, or better yet, simply use the convention: `${APP_NAME}-${ENVIRONMENT}-artifacts-${AWS_ACCOUNT_ID}`.

For simplicity in this guide, we assume the bucket name is known `myapp-staging-artifacts-<ACCOUNT_ID>`.

**File: `.github/workflows/deploy-staging.yml`**

```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]

env:
  GO_VERSION: '1.21'
  AWS_REGION: ap-southeast-1
  # Update this to match the bucket created by Stack 2
  # Format: myapp-staging-artifacts-<YOUR_ACCOUNT_ID>
  S3_BUCKET: myapp-staging-artifacts-123456789012
  CODEPIPELINE_NAME: myapp-staging-pipeline

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: { go-version: ${{ env.GO_VERSION }} }

      # ... Build Steps (Test, Build, Zip) ...

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Upload to S3
        run: |
          aws s3 cp myapp.zip s3://${S3_BUCKET}/staging/myapp-staging.zip

      - name: Trigger CodePipeline
        run: |
          aws codepipeline start-pipeline-execution --name ${CODEPIPELINE_NAME}
```

---

## 🔍 Phase 4: Deployment & Verification

1.  **Push Code**: Commit your changes and push to the `develop` branch.
2.  **GitHub Actions**: Watch the workflow build the Go binary and upload it to S3.
3.  **CodePipeline**: Automatically triggered by S3 upload (or manual trigger via GitHub Actions). It will deploy the new code to the EC2 instances in the ASG.
4.  **Verify**:
    - Check the **Pipeline URL** output from the deployment script.
    - Visit the **Application URL** (ALB DNS) to see your app running.

---

## 📊 Phase 5: Monitoring & Maintenance

CloudFormation Stack 5 already set up a CloudWatch Dashboard for you.

### Accessing the Dashboard

1.  Go to **CloudWatch** console.
2.  Select **Dashboards** from the sidebar.
3.  Click on `myapp-staging-monitoring`.

You will see real-time charts for:

- ALB Request Counts (2XX, 4XX, 5XX)
- EC2 CPU Utilization

### Alarms

Two alarms were created automatically:

- **High CPU**: Triggers if CPU > 80%.
- **Unhealthy Hosts**: Triggers if ALB detects unhealthy instances.

---

## 🐛 Troubleshooting

### CloudFormation Errors

- **"AlreadyExists"**: If you try to create a stack that exists. Use `aws cloudformation update-stack` or delete the stack first if you are starting fresh.
- **"ExportName defined multiple times"**: Ensure you invoke the script with a unique environment (e.g., `staging` vs `dev`).
- **Rollback**: If a stack fails, it defaults to `ROLLBACK_COMPLETE`. You must delete the stack before trying again.

### Deployment Fails

- Check **CodeDeploy** logs in the AWS Console.
- SSH into an instance:
  ```bash
  ssh -i myapp-key.pem ec2-user@<IP_ADDRESS>
  tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
  tail -f /opt/myapp/logs/error.log
  ```

---

## 🧹 Clean Up

To remove all resources, delete the stacks in **reverse order**:

```bash
aws cloudformation delete-stack --stack-name myapp-staging-observability
aws cloudformation delete-stack --stack-name myapp-staging-cicd
aws cloudformation delete-stack --stack-name myapp-staging-app-infra
aws cloudformation delete-stack --stack-name myapp-staging-iam-storage
aws cloudformation delete-stack --stack-name myapp-staging-network
```

> **Note**: S3 buckets containing objects might not delete automatically. You may need to empty them manually first.
