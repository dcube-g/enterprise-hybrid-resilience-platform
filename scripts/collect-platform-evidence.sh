#!/usr/bin/env bash

set -u

echo "=========================================="
echo "Enterprise Resilience Platform"
echo "Platform Evidence Collection"
echo "=========================================="
echo

echo "=== Git ==="
git branch --show-current
git log -1 --oneline
git status --short
echo

echo "=== Azure Account ==="
az account show \
  --query "{subscription:name,subscriptionId:id,tenantId:tenantId}" \
  -o table
echo

echo "=== Primary AKS ==="
az aks show \
  --resource-group core-res-prod-cus-hub-rg \
  --name core-res-prod-cus-aks-app01 \
  --query "{name:name,location:location,kubernetesVersion:kubernetesVersion}" \
  -o table
echo

echo "=== DR AKS ==="
az aks show \
  --resource-group core-res-prod-sin-rg \
  --name core-res-prod-sin-aks-dr01 \
  --query "{name:name,location:location,kubernetesVersion:kubernetesVersion}" \
  -o table
echo

echo "=== Traffic Manager ==="
az network traffic-manager profile show \
  --resource-group core-res-prod-global-rg \
  --name core-res-prod-global-tm \
  --query "{name:name,status:profileStatus,routingMethod:routingMethod,dnsName:dnsConfig.fqdn}" \
  -o table
echo

echo "=== Primary AKS Workloads ==="
az aks get-credentials \
  --resource-group core-res-prod-cus-hub-rg \
  --name core-res-prod-cus-aks-app01 \
  --overwrite-existing

kubectl get nodes -o wide
echo
kubectl get pods -n resilience-app -o wide
echo
kubectl get svc -n resilience-app
echo

echo "=== Primary Application Health ==="
kubectl get deployment -n resilience-app
echo

echo "=== DR AKS Workloads ==="
az aks get-credentials \
  --resource-group core-res-prod-sin-rg \
  --name core-res-prod-sin-aks-dr01 \
  --overwrite-existing

kubectl get nodes -o wide
echo
kubectl get pods -n resilience-app -o wide
echo
kubectl get svc -n resilience-app
echo

echo "=== Azure Backup Foundation ==="
az dataprotection backup-vault show \
  --resource-group core-res-prod-cus-hub-rg \
  --vault-name core-res-prod-cus-backup-vault \
  --query "{name:name,location:location,storageSettings:storageSettings,type:properties.storageSettings[0].type}" \
  -o table

echo
echo "=== Active Backup Instances ==="
az dataprotection backup-instance list \
  --resource-group core-res-prod-cus-hub-rg \
  --vault-name core-res-prod-cus-backup-vault \
  -o table

echo
echo "=== Governance / Resource Lock ==="
az lock list \
  --resource-group core-res-prod-cus-hub-rg \
  --query "[].{name:name,level:level,notes:notes}" \
  -o table
echo

echo "=== Production Resource Tags ==="
az group show \
  --name core-res-prod-cus-hub-rg \
  --query "tags" \
  -o json
echo

echo "=== Production AKS Tags ==="
az aks show \
  --resource-group core-res-prod-cus-hub-rg \
  --name core-res-prod-cus-aks-app01 \
  --query "tags" \
  -o json
echo

echo "=== DR Resource Tags ==="
az group show \
  --name core-res-prod-sin-rg \
  --query "tags" \
  -o json
echo

echo "=== Production Node Pools ==="
az aks nodepool list \
  --resource-group core-res-prod-cus-hub-rg \
  --cluster-name core-res-prod-cus-aks-app01 \
  --query "[].{name:name,vmSize:vmSize,count:count,mode:mode,autoScaling:enableAutoScaling}" \
  -o table
echo

echo "=== DR Node Pools ==="
az aks nodepool list \
  --resource-group core-res-prod-sin-rg \
  --cluster-name core-res-prod-sin-aks-dr01 \
  --query "[].{name:name,vmSize:vmSize,count:count,mode:mode,autoScaling:enableAutoScaling}" \
  -o table
echo

echo "=== Production Kubernetes Health ==="
az aks get-credentials \
  --resource-group core-res-prod-cus-hub-rg \
  --name core-res-prod-cus-aks-app01 \
  --overwrite-existing

kubectl get nodes
kubectl get pods -A
echo

echo "=== FinOps Budget ==="
az rest \
  --method get \
  --url "https://management.azure.com/subscriptions/$(az account show --query id -o tsv)/providers/Microsoft.CostManagement/budgets/resilience-monthly-budget?api-version=2026-06-01" \
  --query "properties.{name:name,amount:amount,timeGrain:timeGrain,notifications:notifications}" \
  -o json
echo

echo "=== Terraform Validation ==="
terraform -chdir=terraform/environments/prod validate
terraform -chdir=terraform/environments/dr validate
terraform -chdir=terraform/environments/global validate
echo

echo
echo "=========================================="
echo "Evidence collection complete"
echo "=========================================="
