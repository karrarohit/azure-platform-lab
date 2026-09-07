resource "azurerm_network_security_group" "aks_user" {
  name                = "nsg-aks-user-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}