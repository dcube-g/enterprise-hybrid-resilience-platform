# Troubleshooting & Fixes Runbook

Main troubleshooting issues, root causes, fixes, workarounds, and validation
steps encountered while implementing the Enterprise Resilience & Disaster
Recovery Platform.


Terraform

Running Terraform from the wrong directory
State locking
Storage deletion protection / non-empty bucket
Compute deletion_protection
Deprecated AzureRM arguments
State/plan files and .gitignore

Container / ACR

Old ACR reference
Multi-architecture amd64/arm64 images
ARM64 manifest issue

Git / CI/CD

fetch first push conflict
Rebase/synchronization workaround
[skip ci]
Trivy missing image argument

Kubernetes
Missing PostgreSQL secret
Deployment rollout troubleshooting
Application health vs pod Running
Public IP quota → ClusterIP for frontend

Argo CD
OutOfSync → refresh/sync

Workload Identity / Key Vault

Primary vs DR client IDs
Environment-specific Kustomize patches
SecretProviderClass troubleshooting

DR

Traffic Manager failover
Failback
RTO/RPO validation boundaries

Azure Backup

Backup foundation vs active Backup Instance
Backup Extension issue
ARM64 compatibility consideration
Regional vCPU quota
Production-capacity workaround
BackupHook/RestoreHook scope

Final validation commands

Terraform
Kustomize
Git
Kubernetes
CI/CD


Azure DevOps

| Problem                                                                  | Workaround / Fix                                                                                  |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Azure DevOps CLI extension installation failed from PowerShell           | Use the WSL Ubuntu environment where Azure CLI/Terraform/Kubectl tooling is already configured    |
| Azure authentication worked in Cloud Shell but not WSL                   | Use authenticated Azure Cloud Shell when Entra/tenant security policy blocks the local login path |
| Pipeline needed to deploy to AKS                                         | Use `AzureCLI@2` with an Azure DevOps service connection and `az aks get-credentials`             |
| Pipeline needed ACR access                                               | Authenticate through Azure CLI and `az acr login` rather than storing registry passwords          |
| Pipeline needed Terraform validation                                     | Run `terraform fmt`, `init`, `validate`, and `plan` independently for `prod`, `dr`, and `global`  |
| Pipeline needed deployment safety                                        | Use an Azure DevOps `environment` such as `resilience-prod` so approvals/checks can be configured |
| Kubernetes deployment completed but application might still be unhealthy | Follow `kubectl rollout status` with an actual `/health` request                                  |
| Trivy failed with `Require at least 1 argument`                          | Ensure the image variable is populated before calling `trivy image`                               |
| Trivy needs to validate multi-architecture images                        | Inspect the manifest and scan both `linux/amd64` and `linux/arm64`                                |
| Infrastructure should not automatically change from CI                   | Keep Terraform CI at `plan`; use a controlled approval/change process for `apply`                 |



GitHub
| Problem                                                                | Workaround / Fix                                                                            |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| CI-generated commit received `fetch first`                             | Fetch/rebase the latest `main` before pushing generated changes                             |
| Automated image-tag commit could retrigger CI                          | Use `[skip ci]` where appropriate                                                           |
| Terraform state appeared locally                                       | Add `*.tfstate`, `*.tfstate.*`, `.terraform/`, etc. to `.gitignore`                         |
| Terraform plans appeared locally                                       | Ignore `*.tfplan` / `*.plan` and don't commit them                                          |
| Sensitive Terraform variables                                          | Ignore `*.tfvars` and keep secrets outside Git                                              |
| CI needs Azure credentials                                             | Use Azure DevOps service connection / federated identity rather than committing credentials |
| Kubernetes environment differs between prod and DR                     | Keep common manifests in `base` and environment-specific changes in Kustomize overlays      |
| Documentation updated directly on GitHub while local branch was behind | Fetch/rebase local work before pushing                                                      |
| Repository needed operational history                                  | Keep architecture, DR validation, runbooks and troubleshooting documentation under `docs/`  |



# GitHub & Azure DevOps Workarounds

This section documents the main source-control and CI/CD workarounds used during implementation of the Enterprise Resilience & Disaster Recovery Platform.

## 1. GitHub Remote Branch Changed During CI

### Symptom

An automated workflow attempted to push a generated change and Git returned:

```text
! [rejected] main -> main (fetch first)
error: failed to push some refs
```

### Cause

The remote `main` branch had changed after the workflow checkout. The CI workspace was therefore behind the remote branch.

### Workaround

Synchronize the local CI branch with the latest remote `main` before pushing the generated change.

Recommended pattern:

```bash
git fetch origin main
git rebase origin/main
```

Then apply the generated change and push:

```bash
git push origin main
```

For CI automation, the workflow should handle this synchronization explicitly rather than assuming the checked-out branch is still current.

### Lesson

Any CI pipeline that commits back to its own repository must account for concurrent changes to the target branch.

---

## 2. Preventing Recursive CI Runs

### Problem

A pipeline-generated commit can trigger the same pipeline again if the repository uses branch-based CI triggers.

### Workaround

Use a commit message containing:

```text
[skip ci]
```

for generated changes where another pipeline execution is unnecessary.

Example:

```text
chore: update image tag [skip ci]
```

### Lesson

Generated repository changes should have an explicit trigger strategy so that CI does not unintentionally create a pipeline loop.

---

## 3. GitHub as Source Control, Azure DevOps as CI/CD

### Design

The project uses GitHub as the source repository and Azure DevOps for CI/CD execution.

```text
GitHub
   |
   | source code
   v
Azure DevOps Pipeline
   |
   +-- Validate
   +-- Build
   +-- Trivy scan
   +-- Terraform validate/plan
   +-- Deploy
   +-- Health verification
   |
   v
AKS
```

### Benefit

This separates source control from deployment automation while allowing Azure-native authentication, AKS deployment, ACR integration, Terraform validation, and Azure DevOps environment controls.

---

## 4. Azure Authentication in Azure DevOps

### Problem

CI/CD requires Azure authentication but long-lived credentials should not be stored in GitHub or pipeline YAML.

### Workaround

Use an Azure DevOps service connection for Azure authentication.

The project uses:

```text
sc-azure-resilience-prod
```

The pipeline can then use Azure DevOps authentication for operations such as:

```bash
az acr login
az aks get-credentials
```

### Lesson

Keep credentials outside source control and let the CI/CD platform provide the authentication context.

---

## 5. Terraform Validation Without Automatic Infrastructure Changes

### Problem

Terraform is required as part of CI/CD, but infrastructure changes should not automatically be applied by every application deployment.

### Workaround

The pipeline performs:

```text
terraform fmt
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan
```

The current pipeline does not automatically execute:

```text
terraform apply
```

### Benefit

Infrastructure changes remain visible through the Terraform plan while application deployment can proceed independently.

### Lesson

Separate infrastructure change management from application deployment when the operational model requires controlled infrastructure changes.

---

## 6. Azure DevOps Deployment Environment

The deployment stage uses an Azure DevOps environment:

```text
resilience-prod
```

This provides a natural control point for future:

* approvals
* checks
* deployment history
* environment-level governance

The existence of the environment should not be described as an approval gate unless an approval/check is actually configured.

---

## 7. Kubernetes Deployment Verification

### Problem

A successful Kubernetes deployment does not necessarily mean the application is healthy.

A pod can be:

```text
Running
```

while the application itself is unavailable.

### Workaround

The pipeline performs both:

```bash
kubectl rollout status
```

and an application health check:

```bash
curl --fail --silent http://127.0.0.1:18080/health
```

### Validation flow

```text
Deployment
    ↓
Pod availability
    ↓
Rollout status
    ↓
Service
    ↓
Application /health
```

### Lesson

CI/CD verification should validate application behavior, not only infrastructure state.

---

## 8. Trivy Image Argument

### Symptom

Trivy returned:

```text
FATAL Fatal error Require at least 1 argument
```

### Cause

The image argument was missing from the Trivy command.

### Workaround

Build the image reference first:

```bash
IMAGE="<acr-login-server>/<repository>:<build-id>"
```

Then pass it explicitly:

```bash
trivy image "$IMAGE"
```

### Lesson

Validate CI variables before using them in security or deployment commands.

---

## 9. Multi-Architecture Image Validation

The project builds:

```text
linux/amd64
linux/arm64
```

using Docker Buildx.

The image manifest can be checked with:

```bash
docker buildx imagetools inspect "$IMAGE"
```

The pipeline also performs architecture-specific Trivy scans.

### Lesson

When Kubernetes nodes may use different CPU architectures, verify the registry manifest rather than assuming a single image tag supports every architecture.

---

## 10. GitHub Repository Hygiene

Terraform-generated files should remain outside source control.

The repository ignores:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
*.plan
*.tfvars
*.tfvars.json
```

Validation:

```bash
git status --short
```

and:

```bash
git ls-files | grep -E '(\.tfstate|\.tfplan|\.tfvars$|\.pem$|\.key$)' || true
```

### Lesson

Source control should contain infrastructure **code**, not local Terraform state, plans, credentials, or generated artifacts.

---

## 11. Recommended Git Workflow

For normal local development:

```bash
git status
```

```bash
git pull --rebase origin main
```

Make the change, then:

```bash
git add <files>
```

```bash
git commit -m "<message>"
```

```bash
git push origin main
```

For CI-generated changes, the pipeline should additionally account for remote branch changes before pushing.

---

## 12. Overall CI/CD Troubleshooting Principle

The project follows this troubleshooting sequence:

```text
Source
  ↓
Validate
  ↓
Build
  ↓
Security Scan
  ↓
Infrastructure Plan
  ↓
Deploy
  ↓
Rollout Verification
  ↓
Application Health
```

When a stage fails, troubleshoot that stage first rather than modifying downstream infrastructure.

This keeps failures isolated, reduces unnecessary changes, and makes the CI/CD process easier to audit and troubleshoot.


## Conclusion

The troubleshooting and workarounds documented here capture the key engineering issues encountered while building and validating the Enterprise Resilience & Disaster Recovery Platform.

The approach throughout the project was to **identify the root cause, apply the least disruptive fix, validate the result, and document the operational lesson**. Where a capability depended on additional production capacity or infrastructure, the platform was kept stable and the production expansion path was documented rather than introducing unnecessary changes to the validated environment.

This runbook should be maintained alongside the architecture, DR validation, and operational documentation as the platform evolves.


## Operator Handoff

For operational handoff, the primary references are:

* `README.md` — platform overview
* `docs/architecture/architecture.md` — architecture and design decisions
* `docs/dr/dr-runbook.md` — DR operational procedure
* `docs/dr/dr-validation.md` — validated DR results and scope
* `docs/operations/troubleshooting-and-fixes.md` — troubleshooting history and workarounds

Before making infrastructure changes:

1. Confirm the working directory and Git status.
2. Review the relevant Terraform/Kubernetes configuration.
3. Run validation and review the Terraform plan where applicable.
4. Follow the approved CI/CD or change-management process.
5. Validate application health after the change.
6. Update the documentation when the operational behavior changes.

For incidents, troubleshoot from the application and Kubernetes layers first, then investigate Azure networking, Traffic Manager, CI/CD, and Terraform as appropriate.

The current documented DR scope covers application availability failover and failback. Transactional data recovery and live Azure-native AKS backup/restore remain production expansion areas.

## Conclusion

The troubleshooting and workarounds documented here capture the key engineering issues encountered while building and validating the Enterprise Resilience & Disaster Recovery Platform.

The approach throughout the project was to **identify the root cause, apply the least disruptive fix, validate the result, and document the operational lesson**. Where a capability depended on additional production capacity or infrastructure, the platform was kept stable and the production expansion path was documented rather than introducing unnecessary changes to the validated environment.

This runbook should be maintained alongside the architecture, DR validation, and operational documentation as the platform evolves.
