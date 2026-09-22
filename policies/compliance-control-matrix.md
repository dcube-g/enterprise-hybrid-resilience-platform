# Compliance Control Matrix

## Enterprise Hybrid Resilience Platform

This document maps the platform's implemented technical controls to
common enterprise governance, security, resilience, and operational
control objectives.

This is an implementation evidence matrix, not a formal certification
against any regulatory framework.

---

## 1. Governance

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Infrastructure protection | Azure Resource Group CanNotDelete lock | Azure management lock |
| Infrastructure as Code | Terraform-managed Azure infrastructure | `terraform/` |
| Configuration consistency | Terraform validation for prod, DR, and global | CI/CD + validation script |
| Resource ownership | Standardized Azure tags | Resource Group / AKS tags |
| Environment separation | Separate prod, DR, and global Terraform environments | `terraform/environments/` |
| Change control | Terraform plan before controlled infrastructure changes | Azure DevOps pipeline |

---

## 2. Identity and Secrets

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Secret management | Azure Key Vault | Key Vault resource |
| Kubernetes secret access | Azure Workload Identity | Federated identity configuration |
| Long-lived credentials | Avoided in application deployment path | Azure DevOps service connection |
| Container registry authentication | Azure-native authentication | ACR / Azure CLI |
| Identity federation | AKS OIDC + federated identity credential | Terraform |

---

## 3. Container and Supply-Chain Security

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Image vulnerability scanning | Trivy HIGH/CRITICAL security gate | CI/CD pipeline |
| Container registry | Azure Container Registry | ACR |
| Multi-architecture validation | ARM64/AMD64 image validation | Troubleshooting documentation |
| Image deployment | Controlled CI/CD deployment | Azure DevOps |

---

## 4. Network Security

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Network segmentation | Azure VNet architecture | Terraform network module |
| AKS networking | Azure CNI overlay | AKS configuration |
| Public exposure control | Controlled service exposure | Kubernetes manifests |
| Global routing | Azure Traffic Manager | Global Terraform environment |
| DR traffic routing | Priority-based failover | DR validation evidence |

---

## 5. Monitoring and Observability

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Metrics collection | Azure Monitor Managed Prometheus | Monitoring configuration |
| Visualization | Azure Managed Grafana | Grafana environment |
| Kubernetes monitoring | ServiceMonitor | Kubernetes monitoring configuration |
| Application health | Kubernetes and application health validation | Operational runbooks |
| Operational troubleshooting | Troubleshooting/fixes documentation | `docs/operations/` |

---

## 6. Resilience and Disaster Recovery

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Production environment | Central US AKS | Production environment |
| DR environment | South India AKS | DR environment |
| Global failover | Azure Traffic Manager | Global environment |
| Failure testing | Controlled primary failure test | DR validation |
| Failover validation | DR endpoint validation | DR evidence |
| Failback | Primary restoration validation | DR evidence |
| RTO/RPO | Documented validation boundaries | `docs/dr/dr-validation.md` |

---

## 7. Backup and Recovery

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Backup foundation | Azure Backup vault | Backup configuration |
| Backup instances | Active Backup Instance validation | Evidence collection |
| Backup troubleshooting | Backup Extension / ARM64 analysis | Troubleshooting documentation |
| Recovery considerations | RestoreHook / BackupHook scope documented | Troubleshooting documentation |

---

## 8. FinOps

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Cost allocation | CostCenter tagging | Azure resource tags |
| Environment classification | Environment tagging | Azure resource tags |
| Criticality classification | Criticality tagging | Azure resource tags |
| DR classification | DRTier tagging | Azure resource tags |
| Data classification | DataClassification tagging | Azure resource tags |
| Budget control | Monthly subscription budget | Cost Management |
| Cost alerting | 80%, 90% forecast, and 100% thresholds | Cost Management budget |
| Cost analysis | Service and resource-group cost analysis | Cost Management Query API |
| Utilization analysis | AKS CPU/memory assessment | FinOps analysis |

---

## 9. CI/CD Governance

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Source control | GitHub | Repository |
| CI/CD execution | Azure DevOps | Pipeline |
| Infrastructure validation | Terraform fmt/init/validate/plan | Pipeline |
| Security gate | Trivy | Pipeline |
| Deployment control | Azure DevOps environment | Pipeline |
| Infrastructure safety | Terraform apply not automatically executed | Pipeline design |
| Application health | Rollout + application health validation | Pipeline / runbook |

---

## 10. Operational Evidence

| Control Area | Implemented Control | Evidence |
|---|---|---|
| Platform evidence | Automated evidence collection script | `scripts/collect-platform-evidence.sh` |
| Troubleshooting history | Documented issues and resolutions | `docs/operations/troubleshooting-and-fixes.md` |
| DR procedures | DR runbook | `docs/dr/dr-runbook.md` |
| DR validation | DR validation document | `docs/dr/dr-validation.md` |
| Architecture | Architecture documentation | `docs/architecture/architecture.md` |
| Terraform validation | Prod/DR/global validation | Evidence collector |

---

## 11. Evidence Collection

The platform provides a repeatable evidence collection mechanism:

```text
scripts/collect-platform-evidence.sh
