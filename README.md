# Blue-Green Deployment with Nginx and Docker Compose

This project implements a **Blue-Green deployment architecture** using **Docker Compose** and **Nginx** as a reverse proxy to route traffic between two versions of the same application — **Blue** (active) and **Green** (standby).

It’s designed to ensure **zero downtime deployments** by seamlessly switching traffic between environments.  
The setup also includes **chaos testing endpoints** to simulate failures and validate fault tolerance.

---

## Project Overview

### Architecture
- **app_blue** → Blue version of the application (`APP_POOL=blue`)
- **app_green** → Green version of the application (`APP_POOL=green`)
- **nginx** → Reverse proxy that routes traffic to either Blue or Green depending on `$ACTIVE_POOL`.

Traffic to `http://localhost:8080` passes through **Nginx**, which proxies requests to the active app container.


---

## Features
- ✅ Blue-Green switch via environment variable and Nginx reload  
- ✅ Zero-downtime switch between versions  
- ✅ Chaos testing endpoints (`/chaos/start`, `/chaos/stop`)  
- ✅ Health and version endpoints for monitoring  
- ✅ Uses Docker internal DNS for app name resolution  

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd blue-green-nginx
```


## 2. Create Environment File

Copy the example `.env` file and adjust if needed:

```bash
cp .env.example .env
```
Example:

ACTIVE_POOL=blue

## 3. Start the Stack
```bash
docker compose up -d
```
This starts:

- **nginx** → on port `8080`
- **app_blue** → on port `8081`
- **app_green** → on port `8082`

## 🧪 Verification

### Check App Health

```bash
curl -i http://localhost:8081/version
curl -i http://localhost:8082/version
```

Both should return `200 OK` with headers indicating which pool they belong to:
- X-App-Pool: blue
- X-Release-Id: blue-v1

or

- X-App-Pool: green
- X-Release-Id: green-v1

##  Switching Environments

To switch Nginx traffic from Blue → Green (or vice versa):

```bash
./switch.sh
```

This script:
- Updates the `ACTIVE_POOL` variable
- Re-renders the Nginx config template
- Reloads Nginx in place (`nginx -s reload`)

You can confirm the switch:

```bash
curl -i http://localhost:8080/version
```

The header should change:
X-App-Pool: green

## Simulating Downtime (Chaos Testing)

Trigger an intentional error on Blue (or Green) to simulate downtime:

```bash
curl -X POST "http://localhost:8081/chaos/start?mode=error"
```

Then check the Nginx endpoint:
```bash
curl -i http://localhost:8080/version
```

If failover is configured, requests will automatically route to the healthy (Green) instance.

Stop chaos mode:
```bash
curl -X POST "http://localhost:8081/chaos/stop"
```





