# Plan 3: Compute Infrastructure

**Objective**: Provision the actual computing resources where the application will run.

## 🏗️ Architecture

This plan deploys:

- **Security Groups**:
  - `ALBSecurityGroup`: Allows HTTP(80) from anywhere 0.0.0.0/0.
  - `EC2SecurityGroup`: Allows HTTP(8080) only from the ALB.
- **Application Load Balancer (ALB)**: Distributes traffic to instances.
- **Launch Template**: Defines the EC2 configuration (AMI, Instance Type, UserData for installing CodeDeploy Agent).
- **Auto Scaling Group (ASG)**: Manages the lifecycle of EC2 instances (scaling out/in).

## 📋 Prerequisites

- **Plan 1 (Networking)**: Requires VPC and Subnets.
- **Plan 2 (IAM)**: Requires `EC2InstanceProfile`.

## 🚀 Execution

Run the following command:

```bash
./aws/deploy-all.sh staging app
```

## ✅ Verification

1. **Get Load Balancer DNS**:

   ```bash
   aws cloudformation describe-stacks \
     --stack-name myapp-staging-app-infra \
     --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
     --output text
   ```

   _Note: Accessing this URL now will return 503 Service Temporarily Unavailable because no app is deployed yet._

2. **Check EC2 Instances**:
   ```bash
   aws ec2 describe-instances \
     --filters "Name=tag:Name,Values=myapp-staging-instance"
   ```
