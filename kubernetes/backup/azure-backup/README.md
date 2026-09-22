# Azure Backup Kubernetes Hooks

This directory contains Azure Backup custom resources for the
`resilience-app` workload.

## Components

- `backup-hook.yaml` - Azure Backup pre/post backup hook.
- `restore-hook.yaml` - Azure Backup post-restore hook.
- `kustomization.yaml` - Kustomize entry point.

## Current project status

Azure Backup hooks are maintained as configuration-as-code and are
validated by CI.

They are not connected to an active Azure Backup runtime on the current AKS cluster.

The BackupHook and RestoreHook custom resources may exist on the cluster,
but the Azure Backup Extension and backup runtime are currently disabled.

The current lab cluster uses an ARM64 node pool and has limited
regional vCPU capacity. The Azure Backup Extension was therefore
removed after it could not be scheduled reliably.

The existing Azure Backup Terraform design and backup storage are
retained as part of the documented Azure-native recovery architecture.

## Activation requirements

Before activating these resources:

1. Install and validate the Azure Backup Extension.
2. Configure the Azure Backup vault and policy.
3. Configure the AKS backup instance.
4. Ensure the Backup Extension can run on supported AKS capacity.
5. Deploy these hook resources to the target namespace.
6. Configure the BackupHook and RestoreHook names in the Azure Backup configuration.

Do not run standalone Velero and the Azure Backup Extension together
on the same cluster.

## Current backup architecture

Primary AKS
    |
    +-- Azure Backup configuration-as-code
    |      |
    |      +-- BackupHook
    |      +-- RestoreHook
    |
    +-- Existing Azure Blob backup storage
    |
    +-- DR AKS

The hooks are configuration-as-code artifacts validated through CI.
They are not connected to an active Azure Backup runtime while the
Azure Backup Extension remains disabled.
