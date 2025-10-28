#!/bin/bash
set -e

CURRENT=$(grep ACTIVE_POOL .env | cut -d'=' -f2)
if [ "$CURRENT" = "blue" ]; then
  NEW="green"
else
  NEW="blue"
fi

echo "Switching traffic from $CURRENT ➜ $NEW"

# Update .env file
sed -i "s/ACTIVE_POOL=.*/ACTIVE_POOL=$NEW/" .env

echo "Reloading nginx with ACTIVE_POOL=$NEW"
docker compose up -d --force-recreate --no-deps nginx

echo "Verifying current active pool..."
sleep 2
curl -s -i http://localhost:8080/version | grep X-App-Pool
