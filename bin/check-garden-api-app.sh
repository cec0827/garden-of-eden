#!/bin/bash
# Example: Check if local HTTP endpoint returns 200 OK within 5 seconds
if ! curl -fsS --max-time 5 http://localhost:5080/health > /dev/null; then
    echo "Health check failed. Restarting garden.service..."
    systemctl restart garden-api.service
fi
