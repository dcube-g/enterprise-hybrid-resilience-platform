# Enterprise Hybrid Resilience Platform
# Disaster Recovery Validation

## 1. Overview

This document records the disaster recovery infrastructure and controlled regional
failover/failback validation for the Enterprise Hybrid Resilience Platform.

Primary region:

- Azure Central US
- AKS: core-res-prod-cus-aks-app01
- Application public endpoint: 48.214.168.255

DR region:

- Azure South India
- AKS: core-res-prod-sin-aks-dr01
- Application public endpoint: 20.44.54.89

Global traffic management:

- Azure Traffic Manager
- Profile: core-res-prod-global-tm
- FQDN: core-res-prod-global-tm.trafficmanager.net
- Routing method: Priority

---

## 2. Traffic Manager Configuration

Primary endpoint:

- Name: core-res-prod-global-primary
- Priority: 1
- Target: 48.214.168.255

DR endpoint:

- Name: core-res-prod-global-dr
- Priority: 2
- Target: 20.44.54.89

Health probe:

- Protocol: HTTP
- Port: 80
- Path: /health
- Probe interval: 30 seconds
- Timeout: 10 seconds
- Tolerated failures: 3

---

## 3. DR Application Validation

The South India DR application was deployed independently to:

core-res-prod-sin-aks-dr01

The DR application was validated through its public LoadBalancer endpoint.

Health endpoint:

http://20.44.54.89/health

Validation result:

HTTP 200 OK

Response:

{"status":"healthy"}

The root application endpoint and Prometheus metrics endpoint were also
validated successfully.

---

## 4. Controlled Failover Test

The primary application deployment was intentionally scaled to zero replicas:

kubectl -n resilience-app scale deployment resilience-app --replicas=0

The primary deployment subsequently reported zero available replicas.

Direct access to the primary endpoint failed:

http://48.214.168.255/health

Traffic Manager health monitoring detected the primary endpoint as degraded.

The South India endpoint remained online.

---

## 5. DNS Failover Validation

After Traffic Manager health detection and DNS propagation/cache expiry,
the Traffic Manager hostname resolved to the South India DR endpoint.

Traffic Manager hostname:

core-res-prod-global-tm.trafficmanager.net

DNS resolution during failover:

20.44.54.89

The following public DNS resolvers also returned the DR endpoint:

- Google DNS: 8.8.8.8
- Cloudflare DNS: 1.1.1.1

The Traffic Manager hostname returned:

HTTP 200 OK

Response:

{"status":"healthy"}

This confirmed successful regional traffic failover.

---

## 6. Primary Recovery

The primary deployment was restored:

kubectl -n resilience-app scale deployment resilience-app --replicas=2

The Central US application subsequently became healthy again.

Direct validation:

http://48.214.168.255/health

Result:

HTTP 200 OK

Response:

{"status":"healthy"}

---

## 7. Controlled Failback Test

After the Central US endpoint returned to an Online state, Traffic Manager
returned DNS priority to the primary endpoint.

DNS resolution after failback:

48.214.168.255

Google DNS:

8.8.8.8 → 48.214.168.255

The Traffic Manager hostname again returned:

HTTP 200 OK

Response:

{"status":"healthy"}

This confirmed successful failback from South India to Central US.

---

## 8. Test Results

| Test | Result |
|---|---|
| Primary application failure | PASS |
| Primary endpoint unavailable | PASS |
| Traffic Manager detected primary failure | PASS |
| DR endpoint remained healthy | PASS |
| DNS selected DR endpoint | PASS |
| Google DNS selected DR endpoint | PASS |
| Cloudflare DNS selected DR endpoint | PASS |
| Traffic Manager hostname served DR application | PASS |
| Primary application restored | PASS |
| Primary endpoint recovered | PASS |
| Traffic Manager primary endpoint returned Online | PASS |
| DNS returned primary endpoint | PASS |
| Traffic Manager hostname served primary application | PASS |
| Regional failover | PASS |
| Regional failback | PASS |

---

## 9. RTO

Recovery Time Objective is measured as the elapsed time between the
intentional primary failure and successful application availability through
the Traffic Manager hostname.

The measured RTO should be recorded from the timestamps captured during the
controlled failover test.

RTO result:

TBD - record measured failover interval from test evidence.

Important:

Traffic Manager uses DNS-based routing. Therefore DNS resolver caching and
client-side DNS caching can affect observed recovery time.

---

## 10. RPO

The current application validation does not include a replicated transactional
database.

Therefore a numeric data-loss RPO has not been demonstrated by this test.

Current documented RPO:

Application availability failover validated.

Transactional data RPO:

TBD - requires implementation and validation of replicated persistent data.

---

## 11. Limitations

The current DR test validates:

- AKS regional recovery
- application availability
- public service exposure
- health monitoring
- DNS-based traffic failover
- DNS-based traffic failback

The current test does not yet validate:

- database replication
- transactional data recovery
- storage replication
- application state replication
- automated data synchronization
- cross-region database failover

These should be addressed if the platform is extended to include persistent
production data.

---

## 12. Conclusion

The controlled regional disaster recovery test successfully demonstrated:

1. Primary application failure.
2. Traffic Manager health detection.
3. DNS-based failover to South India.
4. Successful application response from the DR region.
5. Restoration of the Central US application.
6. DNS-based failback to Central US.
7. Successful end-to-end application response after failback.

The infrastructure and application-level regional failover/failback path is
therefore validated.
