# azure-platform-lab

A hands-on lab for building a production-shaped Azure platform from the ground up:
network, container registry, AKS, delivery pipeline, secrets, observability and a
small ML workflow — with the Terraform underneath maturing at each stage.

Everything is learned **locally first** wherever a local equivalent exists, so Azure
spend starts only when the concept is already understood.

## Repository layout

| Path | What lives here |
| --- | --- |
| `app/` | The FastAPI service under test. Health and readiness endpoints, containerised, non-root. |
| `k8s/` | Plain Kubernetes manifests for the local `kind` lab. Replaced by a Helm chart at stage 2. |
| `terraform/environments/dev/` | Azure infrastructure. Local state for now; remote state arrives at stage 9. |
| `docs/` | Notes for each stage, written as the stage is completed. |

## The application

A deliberately small FastAPI service, so that the platform around it is the
interesting part.

| Endpoint | Purpose |
| --- | --- |
| `GET /health` | Liveness. Process-local only — never checks a dependency. |
| `GET /ready` | Readiness. Whether this instance should receive traffic. |
| `GET /info` | Reports injected configuration and which pod answered. |

The `/health` and `/ready` split is not decorative: it maps directly onto the two
Kubernetes probes, which have very different consequences. See
[docs/01-kubernetes-fundamentals.md](docs/01-kubernetes-fundamentals.md).

## Roadmap

| # | Stage | Status |
| --- | --- | --- |
| 1 | Kubernetes fundamentals (local, on `kind`) | In progress — [notes](docs/01-kubernetes-fundamentals.md) |
| 2 | Helm | Not started |
| 3 | Azure Container Registry | Not started |
| 4 | AKS | Subnets and NSG provisioned; cluster not created |
| 5 | Azure DevOps delivery | Not started |
| 6 | Secrets and security | Not started |
| 7 | Observability and troubleshooting | Not started |
| 8 | ML pipeline | Not started |
| 9 | Terraform maturity | Local state, single environment |

## Infrastructure provisioned so far

Resource group `rg-platformlab-dev` in `eastus`, containing a `10.20.0.0/16` virtual
network carved into three subnets:

| Subnet | Range | Purpose |
| --- | --- | --- |
| `snet-aks-system-dev` | `10.20.1.0/24` | AKS system node pool |
| `snet-aks-user-dev` | `10.20.2.0/24` | AKS user node pool |
| `snet-private-endpoints-dev` | `10.20.3.0/24` | Private endpoints |

An NSG is attached to the user subnet allowing `AzureLoadBalancer` and intra-vnet
inbound traffic, and denying inbound from `Internet` at priority 4000.

> **Note for stage 4:** Azure Load Balancer does not rewrite the source IP for
> data-plane traffic — only for health probes. Public ingress therefore arrives with
> the original client IP and matches `Deny-Internet-Inbound`. Any ingress allow rule
> must use a priority **below 4000** to be evaluated first.

## Cost control

- Local `kind` clusters cost nothing; prefer them for anything that does not
  specifically exercise an Azure feature.
- Kubernetes resource *requests*, not actual usage, determine how many nodes AKS
  bills for. Set them from measurements.
- Tear down Azure resources between sessions: `terraform destroy` in
  `terraform/environments/dev/`.

## Running things

```bash
# Terraform
cd terraform/environments/dev
terraform init && terraform plan

# Local Kubernetes lab
cd k8s && cat README.md
```
