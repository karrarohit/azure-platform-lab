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