# Task 2: Deployment Configuration Files

**Objective**: Create the scripts and configuration files required by AWS CodeDeploy and Systemd.

## 2.1 File Structure

```bash
mkdir -p deployments/scripts deployments/systemd
```

## 2.2 Systemd Service (`deployments/systemd/myapp.service`)

Defines how the application runs as a background service on Amazon Linux 2.

## 2.3 CodeDeploy Specification (`deployments/appspec.yml`)

Maps the source files to destination on EC2 and defines lifecycle hooks.

## 2.4 Lifecycle Hooks (`deployments/scripts/*.sh`)

- `stop_server.sh`: Gracefully stops the service.
- `install_dependencies.sh`: Sets up users and folders.
- `start_server.sh`: Starts the service.
- `validate_service.sh`: Performs health check.

**Action**: Make scripts executable:

```bash
chmod +x deployments/scripts/*.sh
```
