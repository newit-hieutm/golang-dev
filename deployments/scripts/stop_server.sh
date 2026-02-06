#!/bin/bash
set -e

exec > >(tee -a /var/log/codedeploy-stop.log)
exec 2>&1

echo "[$(date)] Starting stop_server.sh"

if systemctl list-units --full --all | grep -q "myapp.service"; then
    if systemctl is-active --quiet myapp.service; then
        echo "Stopping myapp service..."
        systemctl stop myapp.service
        
        for i in {1..30}; do
            if ! systemctl is-active --quiet myapp.service; then
                echo "Service stopped successfully"
                break
            fi
            echo "Waiting for service to stop... ($i/30)"
            sleep 1
        done
    else
        echo "Service is not running"
    fi
else
    echo "Service does not exist yet (first deployment)"
fi

echo "[$(date)] Completed stop_server.sh"
