# Task 3: Infrastructure Provisioning

**Objective**: Deploy the AWS CloudFormation stacks using the provided scripts.

## 3.1 Review Stacks

Check the `aws/cloudformation/` directory to understand what will be created.

## 3.2 Deploy Network & Security

```bash
./aws/deploy-all.sh staging network
./aws/deploy-all.sh staging iam
```

## 3.3 Deploy Application Infrastructure

```bash
./aws/deploy-all.sh staging app
```

_Save the ALB DNS output._

## 3.4 Deploy CI/CD & Monitoring

```bash
./aws/deploy-all.sh staging cicd
./aws/deploy-all.sh staging observability
```

_Save the Pipeline URL output._
