# Master Task List

Use this checklist to track your migration progress.

- [x] **Task 1: Local Setup** ([Details](tasks/01_local_setup.md)) ✅ COMPLETED
  - [x] Initialize Go Module
  - [x] Create `cmd/api/main.go`
  - [x] Create `Makefile`

- [x] **Task 2: Deployment Config** ([Details](tasks/02_deployment_config.md)) ✅ COMPLETED
  - [x] Create Systemd Service File
  - [x] Create AppSpec.yml
  - [x] Create Deployment Scripts (Start/Stop/Validate)

- [ ] **Task 3: Infrastructure** ([Details](tasks/03_infra_provisioning.md))
  - [ ] Deploy Network Stack
  - [ ] Deploy IAM/Storage Stack
  - [ ] Deploy App Infra Stack
  - [ ] Deploy CI/CD & Observability
- [ ] **Task 4: CI/CD Setup** ([Details](tasks/04_github_integration.md))
  - [ ] Create GitHub Action Workflow
  - [ ] Add Secrets to GitHub
  - [ ] Push Code & Verify
