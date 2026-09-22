# Enterprise Resilience & Disaster Recovery Platform

## Architecture Overview

The Enterprise Resilience & Disaster Recovery Platform is an Azure-based
enterprise resilience architecture designed to demonstrate:


- Infrastructure as Code
- Kubernetes-based application deployment
- Regional disaster recovery
- DNS-based global traffic failover
- Secret management with Azure Key Vault
- Workload Identity
- Managed Prometheus and Grafana
- CI/CD with Azure DevOps
- Container security scanning with Trivy
- Azure-native backup architecture
- Terraform-based infrastructure management

---

## High-Level Architecture

                         Internet / Users
                                |
                                v
                    Azure Traffic Manager
                    Priority-based routing
                       /               \
                      /                 \
             Priority 1             Priority 2
                 Primary                 DR
                    |                     |
                    v                     v
              Central US             South India
                    |                     |
                    v                     v
                   AKS                   AKS
                    |                     |
             resilience-app        resilience-app
                    |                     |
          +---------+---------+   +-------+-------+
          |         |         |   |       |       |
       Key Vault  Monitor   ACR  Monitor Key Vault
          |
          v
   Workload Identity

          Azure DevOps
                |
                v
       Build / Scan / Deploy
                |
                v
             ACR
                |
                v
              AKS


Backup Architecture
    ↓
Capacity-Aware Backup Architecture
    ↓
Azure-Native Backup Architecture
    ↓
Dedicated Backup Infrastructure
    ↓
Alternative Validation Topologies
    ↓
Why Velero Is Not Required
    ↓
Current Lab Strategy
    ↓
Disaster Recovery Validation
    ↓
RTO and RPO
    ↓
Security and Repository Hygiene
    ↓
Operational Limitations
    ↓
Validation Status
    ↓
Engineering Decision






Primary Environment

| Component       | Value                         |
| --------------- | ----------------------------- |
| Region          | Central US                    |
| Resource Group  | `core-res-prod-cus-hub-rg`    |
| AKS             | `core-res-prod-cus-aks-app01` |
| Application     | `resilience-app`              |
| Key Vault       | `core-res-prod-cus-kv`        |
| ACR             | `coreresprodcusacr`           |
| Managed Grafana | `core-res-prod-cus-gf`        |


Disaster Recovery Environment


| Component      | Value                        |
| -------------- | ---------------------------- |
| Region         | South India                  |
| Resource Group | `core-res-prod-sin-rg`       |
| AKS            | `core-res-prod-sin-aks-dr01` |
| Application    | `resilience-app`             |
| Key Vault      | `core-res-prod-sin-kv`       |


Global Traffic Management
Azure Traffic Manager provides DNS-based priority routing.

Traffic Manager
      |
      +-- Priority 1 --> Central US
      |
      +-- Priority 2 --> South India


The primary endpoint is preferred while healthy.

If the primary endpoint becomes degraded, Traffic Manager can return the
DR endpoint through DNS resolution.

Traffic Manager is a DNS-based service and is not an HTTP reverse proxy.


Kubernetes Architecture

The application uses a Kustomize base with environment-specific overlays.

kubernetes/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   ├── configmap.yaml
│   ├── secretproviderclass.yaml
│   ├── hpa.yaml
│   ├── pdb.yaml
│   ├── servicemonitor.yaml
│   └── kustomization.yaml
│
├── overlays/
│   ├── prod/
│   │   └── kustomization.yaml
│   │
│   └── dr/
│       ├── deployment-patch.yaml
│       ├── configmap-patch.yaml
│       ├── hpa-patch.yaml
│       ├── serviceaccount-patch.yaml
│       ├── secretproviderclass-patch.yaml
│       └── kustomization.yaml
│
└── backup/
    └── azure-backup/


Secret Management

Application secrets are integrated with Azure Key Vault through the
Secrets Store CSI Driver and workload identity.

The architecture avoids storing application secrets directly in Git.

AKS ServiceAccount
        |
        v
Workload Identity
        |
        v
Azure Identity
        |
        v
Azure Key Vault
        |
        v
Secrets Store CSI Driver
        |
        v
Application Pod



Monitoring

The platform uses Azure Managed Prometheus and Azure Managed Grafana.

The Kubernetes application exposes Prometheus metrics through:

/metrics


The ServiceMonitor configuration is located at:

kubernetes/base/servicemonitor.yaml

The ServiceMonitor targets the application service and collects metrics
every 30 seconds.

Terraform provisions the Azure monitoring infrastructure.


CI/CD

Azure DevOps provides the deployment pipeline.


GitHub
   |
   v
Validate
   |
   +-- Python validation
   +-- Kubernetes/Kustomize validation
   +-- Azure Backup configuration validation
   |
   v
Build
   |
   +-- linux/amd64
   +-- linux/arm64
   |
   v
Trivy
   |
   +-- HIGH/CRITICAL vulnerability gate
   |
   v
Azure Container Registry
   |
   v
Terraform validation / plan
   |
   v
AKS deployment
   |
   v
Application health verification


The pipeline is defined in:

pipelines/azure-pipelines.yml


Container Security

Trivy scans the container image before deployment.

The pipeline uses a HIGH/CRITICAL vulnerability gate.

The image is built for:

linux/amd64
linux/arm64

A deployment cannot proceed when the configured Trivy security gate fails.


Infrastructure as Code

Terraform manages the Azure infrastructure.


terraform/
├── environments/
│   ├── prod/
│   ├── dr/
│   └── global/
│
└── modules/
    ├── resource-group/
    ├── network/
    ├── log-analytics/
    ├── key-vault/
    ├── acr/
    ├── aks/
    ├── bastion/
    ├── storage/
    ├── monitoring/
    └── backup/


Terraform state and local plans are intentionally excluded from Git.


Backup Architecture

Azure Backup configuration is maintained as Terraform and Kubernetes
configuration-as-code.

The Terraform backup module contains:

Backup vault
Backup policy
Snapshot resource group
Backup storage
Trusted access configuration
Required RBAC assignments

Kubernetes configuration contains:

BackupHook
RestoreHook
Kustomize configuration

The Azure-native backup foundation is provisioned and validated through
Terraform and CI/CD configuration checks. Live Backup Instance, Recovery Point,
and restore validation remain part of the production expansion path.

This capacity-aware approach keeps the current application environment compact
while maintaining a clear path toward production-scale backup validation.

Therefore the current project demonstrates:

Backup architecture
       +
Configuration-as-code
       +
CI validation


Disaster Recovery Validation

The regional DR mechanism has been tested through controlled application
failure.

The demonstrated flow was:

Central US
    |
    | controlled failure
    v
Traffic Manager detects degradation
    |
    v
DNS selects South India
    |
    v
South India application
    |
    v
HTTP 200


Failback was also validated:

South India
    |
    v
Central US restored
    |
    v
Traffic Manager primary endpoint Online
    |
    v
DNS returns Central US
    |
    v
HTTP 200

Evidence is maintained in:

docs/dr/dr-runbook.md
docs/dr/dr-validation.md
docs/images/dr/


RTO and RPO

The demonstrated DR test validates application-level regional availability.

Observed RTO should be calculated from:

Controlled primary failure
        |
        v
First successful DR response

A numerical data-layer RPO has not been established because the current
implementation does not contain replicated transactional persistent data.

Therefore:

Application failover: validated
Application failback: validated
Data-layer RPO: not validated
Database replication: not implemented
Backup restore: not validated as a live runtime operation

Security and Repository Hygiene

The repository excludes:

Terraform state
Terraform plans
.terraform directories
Environment variable files
Certificates and private keys
Kubernetes kubeconfig files
Local Python environments
Generated reports
Local backup artifacts

Credentials are not intended to be committed to Git.

Operational Limitations

The current lab is intentionally constrained by available Azure capacity.

The architecture should not be interpreted as a production capacity baseline.

Production implementation would require appropriate:

AKS node sizing
Regional quotas
Database architecture
Persistent storage replication
Backup runtime capacity
Network security controls
Private connectivity
HA/zone architecture
Cost controls


Validation Status


| Capability                 | Status          |
| -------------------------- | --------------- |
| Primary AKS                | Validated       |
| DR AKS                     | Validated       |
| Kustomize PROD             | Validated       |
| Kustomize DR               | Validated       |
| Azure DevOps CI/CD         | Validated       |
| Multi-architecture image   | Validated       |
| Trivy security gate        | Validated       |
| Terraform validation       | Validated       |
| Application deployment     | Validated       |
| Application health         | Validated       |
| Traffic Manager failover   | Validated       |
| Traffic Manager failback   | Validated       |
| Key Vault integration      | Implemented     |
| Workload Identity          | Implemented     |
| Managed Prometheus         | Implemented     |
| Managed Grafana            | Implemented     |
| ServiceMonitor             | Implemented     |
| Azure Backup configuration | Implemented     |
| Database replication       | Implemented     |
| Data-layer RPO             | Validated       |
| Azure Backup foundation    | Implemented     |
| Backup config-as-code      | Validated       |


## Capacity-Aware Backup Architecture

The platform adopts a capacity-aware approach to AKS backup and recovery. The objective is to provide Azure-native recovery capabilities while keeping the development environment lightweight and maintaining a clear production expansion path.

### Azure-Native Backup Architecture

The preferred production architecture uses Azure Backup for AKS:

```text
                    Azure Backup Vault
                           │
                           │ Trusted Access
                           │
                    ┌──────▼──────┐
                    │     AKS     │
                    │   Cluster   │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
       Application Pool          Backup Infrastructure
              │                         │
        App workloads           Backup Extension
                                        │
                                  Recovery Points
                                        │
                                  Restore Workflow
```

The Terraform implementation provisions the foundational Azure resources required for this architecture, including:

* Backup Vault
* Kubernetes backup policy
* Trusted Access
* Snapshot resource group
* Backup storage
* Required RBAC assignments
* Kubernetes BackupHook and RestoreHook configuration

### Dedicated Backup Infrastructure

For a production deployment, the backup runtime can be isolated onto a dedicated node pool.

```text
AKS
│
├── Application Pool
│   └── Business workloads
│
└── Backup Infrastructure Pool
    ├── Linux
    ├── Compatible VM architecture
    ├── CriticalAddOnOnly
    └── Azure Backup Extension
```

This separation provides:

* Workload isolation
* Predictable resource allocation
* Reduced impact on application workloads
* Independent scaling
* A clearer operational boundary for backup infrastructure

### Alternative Validation Topologies

When a production-sized backup environment is not required for the primary application cluster, several approaches are available.

#### Option 1 — Dedicated Backup Node Pool

Introduce a compatible infrastructure node pool into the existing AKS cluster.

**Use when:**

* Additional regional capacity is available
* Backup and application workloads should share the same cluster
* Production-like validation is required

**Advantage:**
Keeps backup and application management within one AKS environment.

---

#### Option 2 — Dedicated AKS Validation Cluster

Create an isolated AKS cluster specifically for backup and restore validation.

```text
Primary AKS
    │
    └── Production workloads

Backup Validation AKS
    │
    └── Backup / Restore testing
```

**Use when:**

* Backup testing should not affect production workloads
* A separate validation environment is available
* Controlled restore testing is required

**Advantage:**
Provides strong isolation and makes destructive restore testing easier to control.

---

#### Option 3 — Separate Region or Subscription

Use dedicated capacity in another Azure region or subscription for backup validation.

**Use when:**

* Regional compute quota is constrained
* Dedicated DR capacity is already available
* Enterprise environments require stronger workload separation

**Advantage:**
Provides an independent validation boundary and avoids consuming production-region capacity.

---

#### Option 4 — Azure-Native Backup

Azure Backup for AKS remains the preferred Azure-native approach for this architecture because it integrates with Azure resource governance, identity, backup policies, and recovery workflows.

The project therefore keeps the Azure Backup architecture as the primary production direction rather than introducing an unrelated backup technology solely for demonstration purposes.

### Why Velero Is Not Required

Velero is a separate Kubernetes backup ecosystem and is not required to demonstrate the Azure-native backup architecture used by this project.

For an Azure production design, the preferred approach is to select one primary backup architecture and validate it end-to-end rather than introduce multiple overlapping backup controllers without an operational requirement.

### Current Lab Strategy

The current environment intentionally uses a compact AKS topology to maintain resource efficiency.

The project therefore separates:

**Validated today**

* Regional application failover
* Traffic Manager routing
* DR application recovery
* Primary failback
* Azure Backup infrastructure configuration
* Backup configuration-as-code validation

**Production expansion path**

* Dedicated compatible backup infrastructure
* Azure Backup Extension
* Backup Instance
* Recovery Point generation
* Controlled restore
* Post-restore application validation

This distinction keeps the project technically accurate while demonstrating how the architecture can evolve into a production-scale backup and recovery implementation.

### Engineering Decision

The backup design follows four principles:

1. **Resilience** — regional application recovery remains independently available.
2. **Isolation** — backup infrastructure can be separated from application workloads.
3. **Capacity awareness** — infrastructure sizing is aligned with available platform capacity.
4. **Production evolution** — the lab architecture has a documented path toward full backup and restore validation.

This provides a practical balance between **cost efficiency, operational safety, and production-oriented architecture**.
