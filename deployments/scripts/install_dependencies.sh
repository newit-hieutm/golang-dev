#!/bin/bash
set -e

exec > >(tee -a /var/log/codedeploy-install.log)
exec 2>&1

echo "[$(date)] Starting install_dependencies.sh"

# Create application user if not exists
if ! id -u myapp > /dev/null 2>&1; then
    echo "Creating myapp user..."
    useradd -r -s /bin/false myapp
fi

# Create directory structure
mkdir -p /opt/myapp/{bin,logs,data}
chown -R myapp:myapp /opt/myapp

echo "[$(date)] Completed install_dependencies.sh"
