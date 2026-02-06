# Plan 1: Networking Foundation

**Objective**: Establish the Virtual Private Cloud (VPC) and network topology required to host the application securely.

## 🏗️ Architecture

This plan deploys the following AWS resources:

- **VPC**: A dedicated virtual network (10.0.0.0/16).
- **Public Subnets**: Two subnets in different Availability Zones (AZs) for high availability.
- **Internet Gateway (IGW)**: Allows public internet access for the subnets.
- **Route Tables**: Configures routes to direct internet traffic via the IGW.

## 📋 Prerequisites

- AWS CLI configured with administrator permissions.

## 🚀 Execution

Run the following command to deploy only the networking layer:

```bash
./aws/deploy-all.sh staging network
```

## ✅ Verification

After deployment, verify the resources:

1. **Check Stack Status**:
   ```bash
   aws cloudformation describe-stacks --stack-name myapp-staging-network
   ```
2. **Verify VPC**:
   ```bash
   aws ec2 describe-vpcs --filters "Name=tag:Name,Values=staging-vpc"
   ```
3. **Verify Subnets**:
   ```bash
   aws ec2 describe-subnets --filters "Name=vpc-id,Values=<VpcId>"
   ```
