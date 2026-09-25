# Basic tier: ~$0.17/day. Cheapest tier that supports what we need, and the
# images outlive the cluster, so tearing the cluster down does not mean
# rebuilding and repushing.
resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"

  # Admin user is a shared username and password. AKS pulls with its managed
  # identity instead, so there is no credential to leak or rotate.
  admin_enabled = false

  tags = local.common_tags
}

# Registry names share one global namespace, so a fixed name eventually
# collides with someone else's.
resource "random_string" "acr_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Lets the cluster's kubelet pull images without any stored credentials.
# This single assignment is the whole of "connect ACR to AKS".
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}
