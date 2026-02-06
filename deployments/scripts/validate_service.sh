#!/bin/bash
set -e

exec > >(tee -a /var/log/codedeploy-validate.log)
exec 2>&1

echo "[$(date)] Starting validate_service.sh"

sleep 5

# Check if service is running
if ! systemctl is-active --quiet myapp.service; then
    echo "ERROR: Service is not running"
    systemctl status myapp.service
    exit 1
fi

# Health check
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT+1))
    echo "Health check attempt $ATTEMPT/$MAX_ATTEMPTS..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "Health check passed!"
        
        VERSION=$(curl -s http://localhost:8080/version || echo "unknown")
        echo "Deployed version: $VERSION"
        
        echo "[$(date)] Service validation successful"
        exit 0
    fi
    
    echo "Health check failed (HTTP $HTTP_CODE), retrying in 2 seconds..."
    sleep 2
done

echo "ERROR: Health check failed after $MAX_ATTEMPTS attempts"
systemctl status myapp.service
journalctl -u myapp.service -n 50
exit 1
