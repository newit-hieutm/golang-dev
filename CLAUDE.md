# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
make build          # Build Linux binary (CGO_ENABLED=0, linux/amd64) to bin/myapp
make build-local    # Build for local platform to bin/myapp
make test           # Run tests with race detection and coverage
make run            # Run locally with go run (serves on :8080)
make clean          # Remove bin/ and coverage.out
make version        # Show version info from git
```

Run a single test: `go test -v -run TestFunctionName ./path/to/package`

The app listens on port 8080 by default, configurable via `-port` flag (e.g., `go run cmd/api/main.go -port 9090`).

Version info (`Version`, `Commit`, `BuildTime`) is injected via ldflags at build time from git metadata.

## Project Details

- **Module**: `github.com/yourorg/myapp` (Go 1.23.5)
- **Dependencies**: Standard library only, no external packages
- **Endpoints**: `GET /health` (returns "OK"), `GET /version` (JSON metadata), `GET /` (hello with hostname)

## Architecture Overview

This is a Go HTTP API deployed to AWS using CloudFormation Infrastructure as Code.

**Application**: Single-binary HTTP server (`cmd/api/main.go`) with graceful shutdown (SIGINT/SIGTERM, 30s timeout). Runs as a systemd service on EC2 instances behind an ALB with auto-scaling.

**Deployment Flow**:
1. PR merged to `main` triggers GitHub Actions workflow (`.github/workflows/deploy.yml`)
2. Workflow runs tests, builds Linux binary, packages with deployment scripts, uploads zip to S3
3. CodePipeline detects the S3 upload and invokes CodeDeploy
4. CodeDeploy performs rolling deployment (OneAtATime) to EC2 instances in ASG
5. Lifecycle hooks: stop service → install deps → start service → validate via `/health`

**AWS Infrastructure** (5 CloudFormation stacks in `aws/cloudformation/`, deployed in order):
1. `1-network.yml` - VPC (10.0.0.0/16), public/private subnets across 2 AZs, NAT gateway
2. `2-iam-storage.yml` - IAM roles (EC2, CodeDeploy, CodePipeline), S3 artifact buckets
3. `3-app-infra.yml` - ALB, ASG, launch template, security groups
4. `4-cicd.yml` - CodePipeline, CodeDeploy application and deployment group
5. `5-observability.yml` - CloudWatch dashboards, alarms (not yet implemented)

Stacks must be deployed in order due to cross-stack references. Deploy with:
```bash
./aws/deploy-all.sh <environment> [plan]   # plan: all|network|iam|app|cicd|observability
./aws/deploy-all.sh staging all             # deploy everything
./aws/deploy-all.sh staging network         # deploy only network stack
```

Cleanup (deletes stacks in reverse order): `./cleanup_stacks.sh`

## Key Paths

- `cmd/api/main.go` - Application entrypoint (handlers, server config, graceful shutdown)
- `deployments/appspec.yml` - CodeDeploy specification (file mappings + lifecycle hooks)
- `deployments/scripts/` - Deployment lifecycle hooks (install, start, stop, validate)
- `deployments/systemd/myapp.service` - Systemd unit file (runs as `myapp` user, security-hardened)
- `.github/workflows/deploy.yml` - CI/CD workflow (test → build → deploy, uses OIDC for AWS auth)
- `plans/` - Architecture design documents for each infrastructure layer
- `tasks/` - Step-by-step implementation guides
