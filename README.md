# Enterprise Resilience & Disaster Recovery Platform

**Infrastructure as Code • Kubernetes • Multi-Region DR • CI/CD • Observability • Security**

An enterprise-style resilience platform demonstrating the design and automation of **highly available, multi-region containerized workloads** with infrastructure as code, automated delivery, security controls, observability, and disaster recovery.

The platform is implemented on **Microsoft Azure** using Terraform, AKS, Azure DevOps, Azure Traffic Manager, Azure Key Vault, Managed Prometheus, Managed Grafana, and Azure Container Registry.

---

## Architecture

```text
                         Global Traffic
                       Azure Traffic Manager
                              │
                 ┌────────────┴────────────┐
                 │                         │
          Primary Region              DR Region
           Central US                South India
                 │                         │
              AKS Cluster              AKS Cluster
                 │                         │
          ┌──────┴──────┐          ┌──────┴──────┐
          │ Application │          │ Application │
          │  Workload   │          │  Workload   │
          └──────┬──────┘          └──────┬──────┘
                 │                         │
                 └──────────┬──────────────┘
                            │
                  Azure Key Vault
                  Workload Identity

        ┌─────────────────────────────────────┐
        │ Terraform • Azure DevOps • Trivy   │
        │ Prometheus • Grafana • Azure Monitor│
        └─────────────────────────────────────┘
```

---

## Key Capabilities

| Area                | Implementation                               |
| ------------------- | -------------------------------------------- |
| Infrastructure      | Terraform modules and environment separation |
| Compute             | Azure Kubernetes Service                     |
| Disaster Recovery   | Multi-region AKS architecture                |
| Global Routing      | Azure Traffic Manager priority failover      |
| CI/CD               | Azure DevOps multi-stage pipeline            |
| Containers          | Multi-architecture Docker images             |
| Security            | Trivy HIGH/CRITICAL vulnerability gate       |
| Secrets             | Azure Key Vault + Workload Identity          |
| Observability       | Managed Prometheus + Managed Grafana         |
| Monitoring          | Kubernetes ServiceMonitor                    |
| Backup Architecture | Azure-native AKS Backup foundation           |
| Configuration       | Kubernetes Kustomize overlays                |
| Operations          | DR runbooks and validation evidence          |

---

## Disaster Recovery

The platform implements a **primary-to-DR regional recovery model**:

**Primary → Central US**
**DR → South India**

The DR workflow includes:

* Health-based traffic monitoring
* Controlled primary failure simulation
* Automatic Traffic Manager failover
* DR application validation
* Recovery-time measurement
* Primary restoration
* Failback validation
* Operational runbook and evidence

The application-level DR workflow has been validated through controlled failover and failback testing.

> **Data-layer RPO:** Transactional database replication is outside the current application scope and therefore is not represented as a validated database RPO.

---

## CI/CD & Security

The Azure DevOps pipeline provides automated:

```text
Validate
   ↓
Build
   ↓
Multi-Architecture Image
   ↓
Trivy Security Scan
   ↓
ACR Push
   ↓
Terraform Validation & Plan
   ↓
AKS Deployment
   ↓
Application Health Verification
```

Security scanning blocks the pipeline on configured **HIGH/CRITICAL vulnerabilities**, while infrastructure changes are validated through Terraform before deployment.

---

## Infrastructure as Code

Terraform is organized into reusable modules and isolated environments:

```text
terraform/
├── modules/
│   ├── aks/
│   ├── network/
│   ├── key-vault/
│   ├── monitoring/
│   ├── backup/
│   └── ...
│
└── environments/
    ├── prod/
    ├── dr/
    └── global/
```

This structure supports repeatable provisioning, controlled changes, environment isolation, and scalable infrastructure management.

---

## Observability

The platform integrates:

* Azure Monitor Managed Prometheus
* Azure Managed Grafana
* Kubernetes ServiceMonitor
* Application health endpoints
* Kubernetes workload health checks

This provides a foundation for **metrics-driven monitoring, alerting, and operational troubleshooting**.

---

## Capacity-Aware Backup Architecture

The platform includes an Azure-native AKS Backup foundation consisting of:

* Backup Vault
* Backup policy
* Trusted Access
* Snapshot infrastructure
* Backup storage
* Kubernetes BackupHook / RestoreHook configuration

The design separates the **application workload topology** from the **backup infrastructure requirements**, allowing the backup runtime to be introduced through a compatible dedicated node-pool topology when additional capacity is available.

This demonstrates a **cost-aware lab implementation with a documented production expansion path**, rather than coupling the application architecture to a specific infrastructure constraint.

---

## Engineering Focus

This project demonstrates practical experience across:

**Cloud Infrastructure**

* Azure architecture
* Networking
* AKS
* Identity and RBAC
* Key Vault
* Traffic management

**DevOps**

* Terraform
* Azure DevOps
* CI/CD automation
* Docker
* Kubernetes
* Kustomize

**SRE & Resilience**

* Multi-region architecture
* Failover/failback
* Health-based routing
* RTO validation
* Operational runbooks
* Observability

**Security**

* Container vulnerability scanning
* Workload Identity
* Secret management
* Least-privilege access
* Infrastructure validation

---

## Repository Structure

```text
enterprise-hybrid-resilience-platform/
├── application/
├── docs/
│   ├── architecture/
│   └── dr/
├── kubernetes/
│   ├── base/
│   ├── overlays/
│   └── backup/
├── pipelines/
├── policies/
└── terraform/
    ├── modules/
    └── environments/
        ├── prod/
        ├── dr/
        └── global/
```

---

## Backup & Recovery Strategy

The platform uses a **layered resilience strategy** combining regional application failover with Azure-native backup architecture.

### Current Design

* Azure-native AKS Backup foundation
* Backup Vault and retention policy
* Trusted Access integration
* Snapshot infrastructure
* Kubernetes BackupHook / RestoreHook configuration
* Multi-region AKS failover through Azure Traffic Manager

The application-level DR path has been validated through controlled failover and failback testing.

### Production Expansion Path

For environments requiring full AKS backup and restore validation, the architecture supports a dedicated backup infrastructure node pool with the capacity and runtime characteristics required by the Azure Backup Extension.

```text
AKS Cluster
│
├── Application Node Pool
│   └── Application workloads
│
└── Backup Infrastructure Node Pool
    ├── Compatible Linux VM architecture
    ├── CriticalAddOnOnly isolation
    └── Azure Backup Extension
```

This approach keeps backup infrastructure isolated from application workloads and provides a clear path from a cost-optimized development environment to a production-scale deployment.

Detailed architecture decisions and alternative recovery approaches are documented in [`docs/architecture/architecture.md`](docs/architecture/architecture.md).


## Production Evolution

The architecture is designed to evolve toward a larger enterprise deployment with:

* Dedicated application and infrastructure node pools
* Expanded backup/restore validation
* Database replication and data-layer RPO
* Private networking and private endpoints
* Centralized policy enforcement
* Advanced alerting and SLOs
* Additional security and compliance controls
* Automated DR orchestration

---

## Outcome

This project brings together **cloud infrastructure, Kubernetes, Terraform, CI/CD, security, observability, and disaster recovery** into a single reproducible platform.

The emphasis is on **automation, resilience, operational evidence, security, and production-oriented engineering practices** rather than isolated technology demonstrations.
