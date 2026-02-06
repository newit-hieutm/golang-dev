# Task 4: GitHub Actions Integration

**Objective**: Connect the GitHub repository to AWS CodePipeline via Actions.

## 4.1 Create Workflow File

Create `.github/workflows/deploy-staging.yml` that:

1. Runs tests.
2. Builds the binary.
3. Zips artifacts (binary + content of `deployments/`).
4. Uploads to S3.
5. Triggers CodePipeline.

## 4.2 Configure Secrets

Go to GitHub Repo Settings -> Secrets and add:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## 4.3 Trigger Deployment

Push code to the configured branch (`develop`) and watch the Actions tab.
