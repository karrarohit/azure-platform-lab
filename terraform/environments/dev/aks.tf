resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.project_name}-${var.environment}"

  # Deliberately one minor version behind the current default, so there is a
  # real upgrade to perform rather than a contrived one.
  kubernetes_version = var.kubernetes_version

  # Free tier: no uptime SLA, and no charge for the control plane. The paid
  # tier buys a financially backed SLA that a lab does not need.
  sku_tier = "Free"

  default_node_pool {
    name            = "system"
    vm_size         = var.node_vm_size
    node_count      = var.node_count
    vnet_subnet_id  = azurerm_subnet.aks_system.id
    os_disk_size_gb = 32

    # Single pool, so application pods share it with system components.
    # A separate user pool comes later, on spot instances.
    only_critical_addons_enabled = false

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Manual means the node pool is exactly the size declared above. The
  # alternative, Auto, lets Azure provision nodes on demand, which is the
  # opposite of predictable cost.
  node_provisioning_profile {
    mode = "Manual"
  }

  # System-assigned means Azure creates and rotates the identity. Nothing to
  # store, nothing to leak.
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    # Overlay mode keeps pod addresses out of the vnet, so the subnet only has
    # to be large enough for nodes rather than every pod. Note the
    # consequence: the VirtualNetwork NSG service tag does not match pod IPs.
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  # Costs nothing to enable and is required for Key Vault integration later.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Container Insights is deliberately NOT enabled. Log Analytics bills per
  # gigabyte ingested and can quietly exceed the cost of the cluster itself.
  tags = local.common_tags
}
