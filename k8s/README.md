# Local Kubernetes lab

Plain manifests for the `kind` cluster used in
[stage 1](../docs/01-kubernetes-fundamentals.md). Replaced by a Helm chart at stage 2 —
these stay as the unabstracted reference.

## Prerequisites

| Tool | Purpose |
| --- | --- |
| Docker Desktop | Runs the kind nodes as containers |
| `kind` | Creates the cluster |
| `kubectl` | Talks to it |

## Create the cluster

```bash
cat > /tmp/kind-platformlab.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: platformlab
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --config /tmp/kind-platformlab.yaml
```

Creating the cluster switches your kubectl context to `kind-platformlab`.

> **Check your context before every session.** If an AKS cluster exists, its context
> may still be selected and these commands would apply to it:
> ```bash
> kubectl config current-context
> ```

## Build and load the image

kind nodes cannot see your local Docker images. They must be loaded explicitly —
there is no registry involved until stage 3.

```bash
docker build -t platformlab-api:0.1.0 ../app
kind load docker-image platformlab-api:0.1.0 --name platformlab
```

## Deploy

```bash
kubectl apply -f .
kubectl rollout status deployment/platformlab-api -n dev
```

| File | Resource |
| --- | --- |
| `00-namespace.yaml` | `dev` namespace |
| `10-configmap.yaml` | Non-confidential settings, injected as env vars |
| `20-deployment.yaml` | 3 replicas, both probes, requests and limits, hardened container |
| `30-service.yaml` | ClusterIP on port 80 → container port 8000 |

## Verify

```bash
kubectl get pods -n dev -o wide
kubectl get endpointslice -n dev

# reach the service from inside the cluster
POD=$(kubectl get pods -n dev -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n dev "$POD" -- python -c \
  "import urllib.request; print(urllib.request.urlopen('http://platformlab-api/info').read())"
```

To reach it from your laptop instead:

```bash
kubectl port-forward -n dev svc/platformlab-api 18000:80
curl http://127.0.0.1:18000/info
```

## Watch it live

```bash
brew install k9s
k9s --context kind-platformlab -n dev
```

## Roll forward and back

```bash
kubectl set image deployment/platformlab-api api=platformlab-api:0.2.0 -n dev
kubectl rollout status  deployment/platformlab-api -n dev
kubectl rollout history deployment/platformlab-api -n dev
kubectl rollout undo    deployment/platformlab-api -n dev
```

Batch related changes into one `apply`. Two separate `kubectl set` commands produce
two revisions and two rollouts.

## Reproduce the failure modes

The failure catalogue in [the stage 1 notes](../docs/01-kubernetes-fundamentals.md#09--logs-events-and-debugging)
was produced with throwaway pods:

| Failure | How |
| --- | --- |
| `ImagePullBackOff` | Reference a tag that was never built, e.g. `platformlab-api:9.9.9` |
| `OOMKilled` | `memory` limit of `64Mi` against a container allocating `400Mi` |
| `Pending` | `cpu` request of `64` — larger than any node |
| `Running`, `0/1 ready` | Point the readiness probe at a path the app does not serve |

## Tear down

```bash
kind delete cluster --name platformlab
```

Costs nothing to leave running, but it does hold memory in Docker Desktop.
