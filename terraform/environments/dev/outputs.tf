output "resource_group_name" {
  description = "Name of the resource group created by Terraform"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Azure resource ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "virtual_network_name" {
  description = "Name of the Azure virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_address_space" {
  description = "Address ranges assigned to the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "aks_system_subnet_name" {
  description = "Name of the subnet reserved for AKS system nodes"
  value       = azurerm_subnet.aks_system.name
}

output "aks_system_subnet_address_prefixes" {
  description = "Address ranges assigned to the AKS system subnet"
  value       = azurerm_subnet.aks_system.address_prefixes
}

output "aks_user_subnet_name" {
  description = "Name of the subnet reserved for AKS application nodes"
  value       = azurerm_subnet.aks_user.name
}

output "private_endpoints_subnet_name" {
  description = "Name of the subnet reserved for private endpoints"
  value       = azurerm_subnet.private_endpoints.name
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Hostname used when tagging and pushing images"
  value       = azurerm_container_registry.main.login_server
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_kubernetes_version" {
  description = "Control plane version currently deployed"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "aks_node_resource_group" {
  description = "Resource group Azure creates for the cluster nodes, disks and load balancer"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer used for workload identity federation in later stages"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "get_credentials_command" {
  description = "Command to point kubectl at this cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

