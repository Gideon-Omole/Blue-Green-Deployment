

## DECISION.md


# Decision Log – Blue-Green Deployment Architecture

## 1. Goal
The goal was to implement a **zero-downtime blue-green deployment strategy** using Docker Compose and Nginx.  
The idea is to always have one version of the app (“Blue”) serving traffic while another version (“Green”) is deployed and tested in parallel.

---

## 2. Architecture Decisions

### a. Nginx as the Traffic Router
I chose Nginx because:
- It’s lightweight and widely used for reverse proxying.
- Supports dynamic upstream reloading (`nginx -s reload`).
- Can route based on environment variables using Docker’s templating feature.

### b. Docker Compose Networking
Using a shared bridge network (`bg-net`) ensures that:
- Nginx can resolve app containers by name (`app_blue`, `app_green`).
- No hardcoded IPs are needed.
- Containers remain isolated from the host while still accessible for local testing.

### c. Blue and Green App Containers
Both containers use the same image but different environment variables:
```yaml
APP_POOL=blue
APP_POOL=green
```
This allows them to identify themselves through headers and simulate version differences (RELEASE_ID).

## 3. Switching Strategy

I implemented a `switch.sh` script that:

- Reads the current active pool
- Flips the value (`blue` → `green` or `green` → `blue`)
- Re-renders the Nginx config template using `envsubst`
- Reloads Nginx seamlessly without downtime

This approach avoids recreating containers and ensures instant cutover.

## 4. Chaos Testing

Each app instance supports chaos simulation via:

- `/chaos/start?mode=error` → forces 500s
- `/chaos/start?mode=timeout` → delays responses

This was key to validating failover behavior.  
When the active app was in chaos mode, Nginx automatically routed traffic to the backup app (Green).

## 5. Challenges and Lessons Learned

- **DNS Resolution**: Early issues occurred because Nginx couldn’t resolve `app_blue` — solved using Docker’s internal DNS (`resolver 127.0.0.11;`).
- **Template Mounting**: Ensuring the Nginx template was mounted in `/etc/nginx/templates` was critical for `envsubst` to work.
- **Timeout Tuning**: Needed proper proxy timeouts to avoid hanging requests during simulated downtime.

---

## 6. Future Improvements

- Automate failover detection based on `/healthz` responses.
- Integrate CI/CD pipeline to trigger `switch.sh` after successful deployment tests.
- Add monitoring to visualize blue-green health and request routing.

---

## 7. Outcome

✅ Achieved seamless, zero-downtime switching between Blue and Green  
✅ Verified recovery and routing using chaos simulation  
✅ Fully Docker Compose-based — no Kubernetes, no manual rebuilds

This project successfully demonstrates a production-ready blue-green deployment pattern using simple, transparent infrastructure.

