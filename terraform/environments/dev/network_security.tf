resource "azurerm_network_security_group" "aks_user" {
  name                = "nsg-aks-user-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# AKS's managed load balancer sends health probes to node ports from the
# AzureLoadBalancer service tag. Required for Service/Ingress health checks
# to succeed once workloads are running in this subnet.
resource "azurerm_network_security_rule" "aks_user_allow_azure_lb_inbound" {
  name                        = "Allow-AzureLoadBalancer-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.aks_user.name
}

# Node-to-node and pod-to-pod traffic within the vnet (system subnet,
# private-endpoints subnet, etc). Kept explicit rather than relying only on
# the NSG's built-in AllowVnetInBound default rule, so it's visible here.
resource "azurerm_network_security_rule" "aks_user_allow_vnet_inbound" {
  name                        = "Allow-VirtualNetwork-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.aks_user.name
}

# Explicit deny for any other inbound traffic from the public internet.
# Redundant with the NSG's default DenyAllInBound rule (priority 65500),
# but kept explicit and high-priority so intent is documented in code and
# survives if default rules are ever overridden.
resource "azurerm_network_security_rule" "aks_user_deny_internet_inbound" {
  name                        = "Deny-Internet-Inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.aks_user.name
}

resource "azurerm_subnet_network_security_group_association" "aks_user" {
  subnet_id                 = azurerm_subnet.aks_user.id
  network_security_group_id = azurerm_network_security_group.aks_user.id
}
