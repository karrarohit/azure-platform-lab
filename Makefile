# Cost control and day-to-day operations for the lab.
# Run `make` with no arguments to list targets.

# Taken from your active `az login` session, so the subscription id never has
# to live in a file or be typed at a prompt.
export TF_VAR_subscription_id := $(shell az account show --query id -o tsv 2>/dev/null)

TF_DIR := terraform/environments/dev
RG     := rg-platformlab-dev
AKS    := aks-platformlab-dev

.DEFAULT_GOAL := help
.PHONY: help plan up creds stop start down nuke billing

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	 | awk 'BEGIN{FS=":.*?## "}{printf "  %-10s %s\n", $$1, $$2}'

plan: ## Show what Terraform would change, without changing anything
	terraform -chdir=$(TF_DIR) init -upgrade
	terraform -chdir=$(TF_DIR) plan

up: ## Create or update the infrastructure. THIS STARTS BILLING.
	terraform -chdir=$(TF_DIR) apply

creds: ## Point kubectl at the cluster
	az aks get-credentials --resource-group $(RG) --name $(AKS) --overwrite-existing
	kubectl config current-context

stop: ## Pause: deallocate nodes. Load balancer, IP, disk and ACR still bill (~$29/mo).
	az aks stop --resource-group $(RG) --name $(AKS)

start: ## Resume a stopped cluster. Takes a few minutes.
	az aks start --resource-group $(RG) --name $(AKS)

down: ## Destroy the cluster, keep ACR and network (~$5/mo). Use this between sessions.
	@echo "Destroying the AKS cluster. Images in ACR and the vnet survive."
	terraform -chdir=$(TF_DIR) destroy -target=azurerm_kubernetes_cluster.main

nuke: ## Destroy everything, including ACR and its images.
	@echo "This removes the registry and every image in it."
	terraform -chdir=$(TF_DIR) destroy

billing: ## Show every resource that currently costs money
	@echo "--- AKS clusters ---"
	@az aks list --query "[].{name:name, power:powerState.code, tier:sku.tier, nodes:agentPoolProfiles[0].count, size:agentPoolProfiles[0].vmSize}" -o table 2>/dev/null || echo "  none"
	@echo "--- container registries ---"
	@az acr list --query "[].{name:name, sku:sku.name}" -o table 2>/dev/null || echo "  none"
	@echo "--- public IPs (bill hourly even when idle) ---"
	@az network public-ip list --query "[].{name:name, sku:sku.name, ip:ipAddress}" -o table 2>/dev/null || echo "  none"
	@echo "--- load balancers ---"
	@az network lb list --query "[].{name:name, sku:sku.name, rg:resourceGroup}" -o table 2>/dev/null || echo "  none"
	@echo "--- managed disks ---"
	@az disk list --query "[].{name:name, gb:diskSizeGb, sku:sku.name}" -o table 2>/dev/null || echo "  none"
