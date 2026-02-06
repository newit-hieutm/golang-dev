# Plan 5: Observability

**Objective**: Set up monitoring and alerting to ensure system health.

## 🏗️ Architecture

This plan deploys:

- **CloudWatch Dashboard**: A centralized view of ALB Request Counts and EC2 CPU.
- **CloudWatch Alarms**:
  - `HighCPU`: Alerts if CPU > 80%.
  - `UnhealthyHosts`: Alerts if ALB sees unhealthy instances.

## 📋 Prerequisites

- **Plan 3 (App Infra)**: Requires ALB and ASG names for metric dimensions.

## 🚀 Execution

Run the following command:

```bash
./aws/deploy-all.sh staging observability
```

## ✅ Verification

1. **View Dashboard**:
   Go to the AWS Console -> CloudWatch -> Dashboards -> `myapp-staging-monitoring`.

2. **Check Alarms**:
   Go to the AWS Console -> CloudWatch -> Alarms. You should see 2 alarms in "OK" state (assuming system is idle/healthy).
