locals {
  resource_group_name  = "rg-${var.project_name}-${var.environment}"
  virtual_network_name = "vnet-${var.project_name}-${var.environment}"

  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}

resource "azurerm_virtual_network" "main" {
  name                = local.virtual_network_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space

  tags = local.common_tags
}