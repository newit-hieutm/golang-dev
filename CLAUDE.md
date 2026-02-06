# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
make build          # Build Linux binary (for deployment) to bin/myapp
make build-local    # Build for local platform
make test           # Run tests with race detection and coverage
make run            # Run locally with go run
make clean          # Remove build artifacts
make version        # Show version info
```

Version info (Version, Commit, BuildTime) is injected via ldflags at build time.

## Architecture Overview

This is a Go HTTP API deployed to AWS using Infrastructure as Code (CloudFormation).

**Application**: Simple HTTP server with `/health`, `/version`, and `/` endpoints. Runs as a systemd service on EC2 instances behind an ALB with auto-scaling.

**Deployment Flow**:
1. PR merged to `main` triggers GitHub Actions workflow
2. Workflow builds Linux binary, packages with deployment scripts, uploads to S3
3. CodePipeline is triggered, which invokes CodeDeploy
4. CodeDeploy performs rolling deployment to EC2 instances in ASG

**AWS Infrastructure** (5 CloudFormation stacks in `aws/cloudformation/`):
- `1-network.yml` - VPC, subnets, routes
- `2-iam-storage.yml` - IAM roles, S3 artifact bucket
- `3-app-infra.yml` - ALB, ASG, EC2 launch template
- `4-cicd.yml` - CodePipeline, CodeDeploy
- `5-observability.yml` - CloudWatch dashboards, alarms

Deploy stacks using: `./aws/deploy-all.sh <environment> [plan]`
- `./aws/deploy-all.sh staging all` - deploy everything
- `./aws/deploy-all.sh staging network` - deploy only network stack

## Key Paths

- `cmd/api/main.go` - Application entrypoint
- `deployments/appspec.yml` - CodeDeploy specification
- `deployments/scripts/` - Deployment lifecycle hooks (start/stop/validate)
- `deployments/systemd/myapp.service` - Systemd service definition
- `.github/workflows/deploy.yml` - CI/CD workflow (triggers on PR merge to main)
