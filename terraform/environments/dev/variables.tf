variable "subscription_id" {
  description = "Azure subscription where lab resources will be deployed"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Short name used to identify project resources"
  type        = string
  default     = "platformlab"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for project resources"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address ranges assigned to the virtual network. Supplied from terraform.tfvars, which is not committed."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Address prefix for each subnet, keyed by role. Supplied from terraform.tfvars, which is not committed."
  type        = map(string)

  validation {
    condition = alltrue([
      for role in ["aks_system", "aks_user", "private_endpoints"] :
      contains(keys(var.subnet_address_prefixes), role)
    ])
    error_message = "subnet_address_prefixes must define aks_system, aks_user and private_endpoints."
  }
}

variable "kubernetes_version" {
  description = "AKS control plane version. Kept one minor behind the current default so an upgrade can be practised."
  type        = string
  default     = "1.34"
}

variable "node_vm_size" {
  description = "VM size for the system node pool. Standard_D2als_v7 is the cheapest x86 size this subscription is allowed in eastus; the B-series is restricted and the cheaper B2pls_v2 is ARM, which would require arm64 images."
  type        = string
  default     = "Standard_D2als_v7"
}

variable "node_count" {
  description = "Nodes in the system pool. One is enough for a lab and is the main cost lever."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "Keep node_count between 1 and 3 in this lab; more is a cost mistake, not a capability."
  }
}

variable "pod_cidr" {
  description = "Address range pods draw from in overlay mode. Must not overlap the virtual network. Supplied from terraform.tfvars."
  type        = string
}

variable "service_cidr" {
  description = "Address range for Kubernetes Service virtual IPs. Must not overlap the virtual network or pod_cidr. Supplied from terraform.tfvars."
  type        = string
}

