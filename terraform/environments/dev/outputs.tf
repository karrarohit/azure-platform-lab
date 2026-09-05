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