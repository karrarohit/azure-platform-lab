# Copy to terraform.tfvars and replace with your own ranges.
# terraform.tfvars is gitignored; this file is the committed template.
#
#   cp example.tfvars terraform.tfvars

vnet_address_space = ["10.0.0.0/16"]

subnet_address_prefixes = {
  aks_system        = "10.0.1.0/24"
  aks_user          = "10.0.2.0/24"
  private_endpoints = "10.0.3.0/24"
}

# AKS internal ranges. Must not overlap vnet_address_space or each other.
# Pods live outside the vnet in overlay mode, so these are cluster-internal.
pod_cidr     = "10.244.0.0/16"
service_cidr = "10.1.0.0/16"
