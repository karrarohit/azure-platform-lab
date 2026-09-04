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