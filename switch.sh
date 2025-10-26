#!/bin/bash
set -e

# Detect current pool
CURRENT_POOL=$(docker exec blue-green-nginx-nginx-1 sh -c 'echo $ACTIVE_POOL')
if [ "$CURRENT_POOL" == "blue" ]; then
  NEW_POOL="green"
else
  NEW_POOL="blue"
fi

echo "Switching traffic from $CURRENT_POOL ➜ $NEW_POOL"

# Update ACTIVE_POOL environment variable
docker exec blue-green-nginx-nginx-1 sh -c "export ACTIVE_POOL=$NEW_POOL && envsubst '\$ACTIVE_POOL' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf"

# Reload nginx
docker exec blue-green-nginx-nginx-1 nginx -s reload

# Confirm
curl -s -I http://localhost:8080/version | grep X-App-Pool || echo "Switch failed"
