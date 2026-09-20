# Enterprise Hybrid Resilience Platform

# Disaster Recovery Runbook

## 1. Purpose

This runbook describes the regional disaster recovery procedure for the Enterprise Hybrid Resilience Platform when the Central US application becomes unavailable.

The architecture uses Azure Traffic Manager with priority-based DNS routing:

```text
                    Azure Traffic Manager
                 core-res-prod-global-tm
                           |
                 Priority-based routing
                    /              \
                   /                \
          Priority 1             Priority 2
             Primary                 DR
                |                     |
           Central US             South India
                |                     |
              AKS                   AKS
                |                     |
        resilience-app        resilience-app
```

---

# 2. Primary Environment

| Component                | Value                         |
| ------------------------ | ----------------------------- |
| Region                   | Central US                    |
| AKS                      | `core-res-prod-cus-aks-app01` |
| Application              | `resilience-app`              |
| Public endpoint          | `48.214.168.255`              |
| Traffic Manager priority | 1                             |

---

# 3. DR Environment

| Component                | Value                        |
| ------------------------ | ---------------------------- |
| Region                   | South India                  |
| AKS                      | `core-res-prod-sin-aks-dr01` |
| Application              | `resilience-app`             |
| Public endpoint          | `20.44.54.89`                |
| Traffic Manager priority | 2                            |

---

# 4. Global Traffic Management

Traffic Manager profile:

```text
core-res-prod-global-tm
```

FQDN:

```text
core-res-prod-global-tm.trafficmanager.net
```

Routing method:

```text
Priority
```

Traffic Manager is DNS-based. It is not an HTTP reverse proxy.

## Health Probe

```text
Protocol: HTTP
Port: 80
Path: /health
Interval: 30 seconds
Timeout: 10 seconds
Tolerated failures: 3
```

## Endpoints

```text
Primary
Target: 48.214.168.255
Priority: 1

DR
Target: 20.44.54.89
Priority: 2
```

---

# 5. Failover Procedure

## 5.1 Verify Primary Application

Check the primary deployment:

```bash
kubectl -n resilience-app get deployment resilience-app
```

Expected baseline:

```text
READY   UP-TO-DATE   AVAILABLE
2/2     2            2
```

Check the primary application directly:

```bash
curl -i --connect-timeout 10 \
  http://48.214.168.255/health
```

Expected:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

---

## 5.2 Verify Traffic Manager Baseline

```bash
az network traffic-manager endpoint list \
  --resource-group core-res-prod-global-rg \
  --profile-name core-res-prod-global-tm \
  -o table
```

Expected:

```text
Primary: Online
DR: Online
```

Verify the Traffic Manager hostname:

```bash
curl -i --connect-timeout 10 \
  http://core-res-prod-global-tm.trafficmanager.net/health
```

Expected:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

---

# 6. Controlled Failover Test

For a controlled resilience test, the primary application can be intentionally stopped.

Before failure injection, record the exact UTC timestamp:

```bash
date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
```

Then scale the primary application to zero:

```bash
kubectl -n resilience-app scale deployment resilience-app --replicas=0
```

Immediately record the timestamp again:

```bash
date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
```

This timestamp is the failure-injection reference for the RTO calculation.

---

# 7. Verify Primary Failure

Check the deployment:

```bash
kubectl -n resilience-app get deployment resilience-app
```

Expected:

```text
0/0
```

Verify that the primary endpoint is unavailable:

```bash
curl -i --connect-timeout 10 \
  http://48.214.168.255/health
```

The request should fail or time out.

---

# 8. Verify Traffic Manager Failure Detection

Check the endpoint state:

```bash
az network traffic-manager endpoint list \
  --resource-group core-res-prod-global-rg \
  --profile-name core-res-prod-global-tm \
  -o table
```

Expected state after health detection:

```text
Primary:
EndpointMonitorStatus: Degraded

DR:
EndpointMonitorStatus: Online
```

Record the timestamp when this state is observed:

```bash
date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
```

---

# 9. Verify DR Endpoint

Test the South India DR endpoint directly:

```bash
curl -i --connect-timeout 10 \
  http://20.44.54.89/health
```

Expected:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

---

# 10. Verify DNS Failover

Query Google Public DNS:

```bash
nslookup core-res-prod-global-tm.trafficmanager.net 8.8.8.8
```

Expected:

```text
Address: 20.44.54.89
```

Query Cloudflare DNS:

```bash
nslookup core-res-prod-global-tm.trafficmanager.net 1.1.1.1
```

Expected:

```text
Address: 20.44.54.89
```

DNS results can temporarily differ because DNS caching and resolver behavior affect when clients observe a routing change.

---

# 11. Verify End-to-End DR Traffic

This is the most important RTO measurement point.

Run:

```bash
curl -i --connect-timeout 10 \
  http://core-res-prod-global-tm.trafficmanager.net/health
```

When the response is:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

record the exact timestamp:

```bash
date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
```

The time between the controlled failure timestamp and this first successful response represents the observed application failover RTO.

---

# 12. Failover Result

Record the result in the test evidence:

| Validation                                   | Result |
| -------------------------------------------- | ------ |
| Primary application stopped                  | PASS   |
| Primary endpoint unavailable                 | PASS   |
| Traffic Manager detected primary degradation | PASS   |
| DR endpoint healthy                          | PASS   |
| DNS selected DR endpoint                     | PASS   |
| Google DNS selected DR endpoint              | PASS   |
| Cloudflare DNS selected DR endpoint          | PASS   |
| Traffic Manager hostname returned HTTP 200   | PASS   |
| DR application served successfully           | PASS   |

---

# 13. Failback Procedure

After completing the failover test, restore the Central US application:

```bash
kubectl -n resilience-app scale deployment resilience-app --replicas=2
```

Monitor rollout:

```bash
kubectl -n resilience-app rollout status \
  deployment/resilience-app
```

Verify:

```bash
kubectl -n resilience-app get deployment resilience-app
```

Expected:

```text
2/2
```

---

# 14. Verify Primary Recovery

```bash
curl -i --connect-timeout 10 \
  http://48.214.168.255/health
```

Expected:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

---

# 15. Verify Traffic Manager Recovery

```bash
az network traffic-manager endpoint list \
  --resource-group core-res-prod-global-rg \
  --profile-name core-res-prod-global-tm \
  -o table
```

Expected:

```text
Primary:
EndpointMonitorStatus: Online
Priority: 1

DR:
EndpointMonitorStatus: Online
Priority: 2
```

---

# 16. Verify DNS Failback

Google Public DNS:

```bash
nslookup core-res-prod-global-tm.trafficmanager.net 8.8.8.8
```

Cloudflare DNS:

```bash
nslookup core-res-prod-global-tm.trafficmanager.net 1.1.1.1
```

Expected primary endpoint:

```text
48.214.168.255
```

---

# 17. Verify End-to-End Failback

```bash
curl -i --connect-timeout 10 \
  http://core-res-prod-global-tm.trafficmanager.net/health
```

Expected:

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

---

# 18. Failback Result

| Validation                                 | Result |
| ------------------------------------------ | ------ |
| Primary application restored               | PASS   |
| Primary endpoint healthy                   | PASS   |
| Traffic Manager primary endpoint Online    | PASS   |
| DNS returned primary endpoint              | PASS   |
| Traffic Manager hostname returned HTTP 200 | PASS   |
| End-to-end failback validation             | PASS   |

---

# 19. RTO Measurement

RTO is measured from the controlled primary failure until the application is successfully reachable through the DR path.

The measurement is:

```text
Observed RTO =
First successful Traffic Manager /health response through DR
-
Controlled primary failure timestamp
```

The Traffic Manager probe interval of 30 seconds must not be reported as the RTO.

The actual measurement should include:

```text
Primary failure
      ↓
Traffic Manager health detection
      ↓
DNS endpoint selection
      ↓
DNS/cache propagation
      ↓
Client request
      ↓
DR application HTTP 200
```

## RTO Evidence

Record:

```text
Failure injection timestamp:
YYYY-MM-DD HH:MM:SS UTC

First successful DR response:
YYYY-MM-DD HH:MM:SS UTC

Observed application RTO:
XX seconds
```

If these timestamps were not captured during a test, the RTO should remain:

```text
Not formally measured
```

rather than using an estimated value.

---

# 20. RPO Measurement

RPO answers a different question:

> How much application data could be lost during a regional failure?

The current application failover test does not establish a numerical RPO because the demonstrated architecture does not include a replicated transactional database/data store.

The current test validates:

```text
Application availability
Traffic routing
Regional recovery
```

It does not validate:

```text
Database replication
Transaction replication
Backup restoration
Data consistency
Recovery-point state
```

Therefore:

```text
Data-layer RPO: Not validated
```

A numerical RPO requires a separate data recovery test.

For example:

```text
Transaction written to primary
          ↓
Replication / backup
          ↓
Primary failure
          ↓
Recover DR data
          ↓
Find latest transaction available
```

Then:

```text
RPO =
Timestamp of last confirmed primary transaction
-
Timestamp of latest transaction available in DR
```

---

# 21. DR Scope Validated

The following capabilities have been demonstrated:

* Azure regional infrastructure
* Central US AKS application
* South India DR AKS application
* Container image availability
* Kubernetes application deployment
* Key Vault/workload identity integration
* Public application endpoints
* Azure Traffic Manager
* DNS-based priority routing
* Regional application failover
* Regional application failback
* Application health validation

---

# 22. DR Scope Not Yet Validated

The following require a separate data-DR phase:

* Database replication
* Database failover
* Transactional data recovery
* Backup restoration
* Data-level RPO measurement
* Cross-region database recovery
* Data consistency validation
* Backup corruption/recovery testing

---

# 23. Final DR Test Assessment

The regional application disaster recovery mechanism has been successfully implemented and tested.

The completed test demonstrated:

```text
Central US
    ↓
Controlled application failure
    ↓
Traffic Manager detects degradation
    ↓
DNS selects South India
    ↓
South India serves the application
```

and recovery:

```text
South India
    ↓
Primary Central US recovery
    ↓
Traffic Manager detects primary recovery
    ↓
DNS returns Central US
    ↓
Central US serves the application
```

The regional application failover and failback mechanism is therefore validated.

The remaining major DR capability is the data layer. Database replication, backup recovery, and transactional RPO measurement require a separate data recovery implementation and test.
