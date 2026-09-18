output "id" {
  description = "AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity_client_id" {
  description = "Kubelet managed identity client ID"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
}

output "kubelet_identity_object_id" {
  description = "Kubelet managed identity object ID"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "identity_principal_id" {
  description = "AKS control plane managed identity principal ID"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}
