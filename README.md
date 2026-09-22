# Enterprise Hybrid Resilience Platform

**Infrastructure as Code • Kubernetes • Multi-Region DR • CI/CD • Observability • Security • Governance • FinOps**

An enterprise-style resilience platform demonstrating the design and automation of highly available, multi-region containerized workloads with Infrastructure as Code, automated delivery, security controls, observability, governance, cost management, and disaster recovery.

The platform is implemented on Microsoft Azure using Terraform, Azure Kubernetes Service (AKS), Azure DevOps, Azure Traffic Manager, Azure Key Vault, Azure Managed Prometheus, Azure Managed Grafana, and Azure Container Registry.

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

| Area              | Implementation                                    |
| ----------------- | ------------------------------------------------- |
| Infrastructure    | Terraform reusable modules                        |
| Environments      | Production / DR / Global                          |
| Compute           | Azure Kubernetes Service                          |
| Primary Region    | Central US                                        |
| DR Region         | South India                                       |
| Disaster Recovery | Multi-region AKS architecture                     |
| Global Routing    | Azure Traffic Manager priority failover           |
| CI/CD             | Azure DevOps multi-stage pipeline                 |
| Containers        | Multi-architecture Docker images                  |
| Registry          | Azure Container Registry                          |
| Security          | Trivy HIGH/CRITICAL vulnerability gate            |
| Identity          | AKS Workload Identity / OIDC federation           |
| Secrets           | Azure Key Vault                                   |
| Observability     | Managed Prometheus + Managed Grafana              |
| Monitoring        | Kubernetes ServiceMonitor                         |
| Backup            | Azure-native AKS Backup foundation                |
| Governance        | Terraform-managed resource protection             |
| FinOps            | Standardized tagging and Azure budget alerts      |
| Compliance        | Compliance control matrix and evidence collection |
| Configuration     | Kubernetes Kustomize overlays                     |
| Operations        | DR runbooks and troubleshooting documentation     |

---

## Disaster Recovery

The platform implements a primary-to-DR regional recovery model.

```text
Primary
Central US
    │
    │ Traffic Manager
    │
    ▼
South India
DR Region
```

The DR workflow includes:

* Health-based traffic monitoring
* Controlled primary failure simulation
* Traffic Manager failover
* DR application validation
* Recovery-time measurement
* Primary restoration
* Traffic failback
* Operational runbook
* Validation evidence

The application-level DR workflow has been validated through controlled failover and failback testing.

### RPO Scope

> **Data-layer RPO:** Transactional database replication is outside the current application scope and therefore is not represented as a validated database RPO.

The validated resilience scope covers application availability, regional failover, traffic redirection, recovery validation, and failback.

---

## CI/CD and Security

The Azure DevOps pipeline implements automated validation and deployment:

```text
Source
  │
  ▼
Validate
  │
  ▼
Build
  │
  ▼
Multi-Architecture Image
  │
  ▼
Trivy Security Scan
  │
  ▼
ACR Push
  │
  ▼
Terraform Validation / Plan
  │
  ▼
AKS Deployment
  │
  ▼
Application Health Verification
```

Security controls include:

* Container vulnerability scanning
* HIGH/CRITICAL vulnerability gate
* Azure Container Registry
* Multi-architecture image validation
* Terraform validation
* Infrastructure plan review
* Kubernetes deployment validation
* Application health verification

---

## Identity and Secrets

The platform uses Azure Key Vault and AKS Workload Identity to avoid embedding long-lived Azure credentials inside application workloads.

```text
AKS
 │
 ├── OIDC Issuer
 │
 ├── Kubernetes ServiceAccount
 │
 └── Federated Identity Credential
              │
              ▼
      Microsoft Entra Identity
              │
              ▼
        Azure Key Vault
```

The federated identity model provides workload-level Azure authentication without requiring permanent Azure credentials inside application containers.

---

## Infrastructure as Code

Terraform is organized into reusable modules and isolated environments.

```text
terraform/
├── environments/
│   ├── prod/
│   ├── dr/
│   └── global/
│
└── modules/
    ├── acr/
    ├── aks/
    ├── backup/
    ├── bastion/
    ├── governance/
    ├── key-vault/
    ├── log-analytics/
    ├── network/
    ├── resource-group/
    ├── storage/
    └── ...
```

This structure provides:

* Repeatable infrastructure provisioning
* Environment separation
* Reusable Terraform modules
* Controlled infrastructure changes
* Consistent resource tagging
* Terraform validation
* Infrastructure drift visibility

---

## Governance and Resource Protection

Production resources are protected through a Terraform-managed Azure resource-group management lock.

```text
Production Resource Group
          │
          └── CanNotDelete
                │
                └── governance-lock-prod
```

The governance implementation is maintained under:

```text
terraform/modules/governance/
```

The lock protects the production resource group against accidental deletion while keeping the governance configuration under Infrastructure as Code.

### Operational Consideration

Azure management locks can affect certain AKS lifecycle operations when Azure-managed resources or extensions require modification.

Any operation requiring temporary lock removal should follow a controlled procedure:

```text
Identify required operation
        │
        ▼
Controlled lock-removal window
        │
        ▼
Perform approved operation
        │
        ▼
Restore governance lock
        │
        ▼
Terraform plan / validation
```

The governance lock remains enabled as the normal production state.

---

## Observability

The platform integrates:

* Azure Monitor Managed Prometheus
* Azure Managed Grafana
* Kubernetes ServiceMonitor
* Application health endpoints
* Kubernetes workload health checks
* Node resource utilization
* Pod resource utilization

This provides a foundation for:

* Metrics collection
* Monitoring
* Alerting
* Troubleshooting
* Capacity assessment
* SRE-oriented operational practices

---

## FinOps and Cost Management

The platform implements standardized resource tagging and Azure Cost Management controls to support cost allocation, ownership, and operational accountability.

### Standard Tags

```text
Environment
Project
ManagedBy
Owner
CostCenter
Criticality
DataClassification
DRTier
```

Example:

```text
CostCenter         = CC-RESILIENCE
Criticality        = High
DataClassification = Internal
DRTier             = Tier-1
ManagedBy          = Terraform
```

### Budget Controls

A monthly Azure Cost Management budget is configured with alerts for:

* Actual cost at 80%
* Forecast cost at 90%
* Actual cost at 100%

The project also includes production and DR AKS utilization assessment.

The utilization review showed low application CPU consumption but relatively higher memory utilization from Kubernetes and monitoring components. Based on the observed workload and system overhead, no AKS node-size reduction was applied.

This follows a measure-first FinOps approach rather than reducing infrastructure capacity without sufficient utilization evidence.

---

## Backup Architecture

The platform includes an Azure-native AKS Backup foundation consisting of:

* Backup Vault
* Backup policy
* Trusted Access
* Snapshot infrastructure
* Backup storage
* Kubernetes BackupHook / RestoreHook configuration

The design separates application workload topology from backup infrastructure requirements.

### Backup Architecture

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

The current implementation documents the backup architecture and production expansion path rather than claiming unsupported full backup/restore validation.

---

## Compliance and Operational Evidence

The repository contains a compliance control matrix:

```text
policies/compliance-control-matrix.md
```

The matrix maps implemented controls and evidence across:

* Governance
* Identity and secrets
* Container security
* Network security
* Monitoring
* Disaster recovery
* Backup
* FinOps
* CI/CD governance
* Operational readiness

The platform also includes an evidence collection script:

```text
scripts/collect-platform-evidence.sh
```

The evidence collector gathers information covering:

* Git state
* Azure subscription
* Primary AKS
* DR AKS
* Traffic Manager
* Kubernetes workloads
* Governance locks
* Resource tags
* AKS node pools
* FinOps budget
* Backup configuration
* Terraform validation

The evidence collection script has been syntax-validated and executed successfully.

> The compliance matrix is an engineering control and evidence mapping document. It is not a formal regulatory certification or independent compliance audit.

---

## Operational Documentation

Operational troubleshooting is documented in:

```text
docs/operations/troubleshooting-and-fixes.md
```

The documentation covers:

* Terraform state and locking
* Azure resource protection
* AzureRM provider changes
* Azure Container Registry
* Multi-architecture containers
* Git and CI/CD issues
* Kubernetes configuration
* Argo CD synchronization
* Workload Identity
* Key Vault integration
* Traffic Manager failover/failback
* AKS Backup constraints
* Azure DevOps operational workarounds

DR procedures are documented under:

```text
docs/dr/
├── dr-runbook.md
└── dr-validation.md
```

---

## Repository Structure

```text
enterprise-hybrid-resilience-platform/
│
├── application/
│
├── docs/
│   ├── architecture/
│   ├── dr/
│   ├── images/
│   └── operations/
│
├── kubernetes/
│   ├── base/
│   ├── overlays/
│   └── backup/
│
├── pipelines/
│
├── policies/
│   └── compliance-control-matrix.md
│
├── scripts/
│   └── collect-platform-evidence.sh
│
└── terraform/
    ├── environments/
    │   ├── prod/
    │   ├── dr/
    │   └── global/
    │
    └── modules/
        ├── acr/
        ├── aks/
        ├── backup/
        ├── bastion/
        ├── governance/
        ├── key-vault/
        ├── log-analytics/
        ├── network/
        ├── resource-group/
        ├── storage/
        └── ...
```

---

## Production Evolution

The architecture is designed to evolve toward a larger enterprise deployment with:

* Dedicated application and infrastructure node pools
* Expanded backup and restore validation
* Database replication and data-layer RPO
* Private networking and private endpoints
* Centralized Azure Policy enforcement
* Advanced alerting and SLOs
* Additional security and compliance controls
* Automated DR orchestration

---

## Final Validation

| Validation                   | Status  |
| ---------------------------- | ------- |
| Terraform Prod validation    | PASS    |
| Terraform DR validation      | PASS    |
| Terraform Global validation  | PASS    |
| Evidence script syntax       | PASS    |
| Platform evidence collection | PASS    |
| DR failover validation       | PASS    |
| DR failback validation       | PASS    |
| Container security gate      | PASS    |
| Governance lock              | ACTIVE  |
| FinOps budget                | ACTIVE  |
| Compliance control matrix    | PRESENT |

The final compliance and closure phase was completed without requiring additional infrastructure changes.

---

## Engineering Outcomes

The project demonstrates an end-to-end enterprise cloud engineering lifecycle:

```text
Architecture
    ↓
Infrastructure as Code
    ↓
Secure CI/CD
    ↓
Kubernetes Platform
    ↓
Identity & Secrets
    ↓
Observability
    ↓
Disaster Recovery
    ↓
Security & Governance
    ↓
FinOps
    ↓
Compliance Evidence
    ↓
Operational Readiness
```

The implementation focuses on:

* Automation
* Repeatability
* Controlled change
* Measurable resilience
* Security-by-design
* Operational evidence
* Cost awareness

The platform is designed as a production-oriented engineering demonstration rather than an isolated collection of technology examples.

---

## Project Status

**Final implementation completed — release preparation in progress.**

Major platform capabilities have been implemented and validated across:

* Azure infrastructure
* Kubernetes
* Terraform
* CI/CD
* Container security
* Identity and secrets
* Observability
* Disaster recovery
* Governance
* FinOps
* Compliance evidence
* Operational documentation

The remaining activity is limited to final repository review, Git commit, push, and release verification.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

