#!/bin/bash
set -e

exec > >(tee -a /var/log/codedeploy-start.log)
exec 2>&1

echo "[$(date)] Starting start_server.sh"

# Set permissions
chown -R myapp:myapp /opt/myapp
chmod +x /opt/myapp/bin/myapp

# Reload systemd
systemctl daemon-reload

# Enable and start service
systemctl enable myapp.service
systemctl start myapp.service

# Wait for service to be active
for i in {1..10}; do
    if systemctl is-active --quiet myapp.service; then
        echo "Service started successfully"
        break
    fi
    echo "Waiting for service to start... ($i/10)"
    sleep 2
done

if ! systemctl is-active --quiet myapp.service; then
    echo "ERROR: Service failed to start"
    systemctl status myapp.service
    exit 1
fi

echo "[$(date)] Completed start_server.sh"
