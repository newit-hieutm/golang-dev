# Plan 2: Security & Storage

**Objective**: Set up the necessary permissions (IAM) and storage buckets (S3) for artifacts and deployment.

## 🏗️ Architecture

This plan deploys:

- **S3 Artifact Bucket**: Stores the versioned build artifacts (`.zip` files).
- **S3 Pipeline Bucket**: Used internally by CodePipeline to pass artifacts between stages.
- **IAM EC2 Role**: Allows EC2 instances to fetch artifacts from S3 and write logs to CloudWatch.
- **IAM CodeDeploy Role**: Allows CodeDeploy to manage EC2 instances and ASGs.
- **IAM CodePipeline Role**: Allows the pipeline to orchestrate the build/deploy flow.

## 📋 Prerequisites

- **Plan 1 (Networking)** must be completed (though strictly speaking, IAM/S3 are global/regional and don't depend on VPC, we follow the sequence).

## 🚀 Execution

Run the following command:

```bash
./aws/deploy-all.sh staging iam
```

## ✅ Verification

1. **Check Buckets**:

   ```bash
   aws s3 ls | grep myapp
   ```

   _You should see two buckets._

2. **Check Roles**:
   ```bash
   aws iam get-role --role-name myapp-staging-ec2-role
   ```
