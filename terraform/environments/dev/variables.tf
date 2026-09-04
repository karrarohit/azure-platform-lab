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
  description = "Private IP address ranges assigned to the virtual network"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}