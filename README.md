# litmus-cd

Infrastructure-as-code and GitOps configuration for the LitmusChaos project's own hosted services.

This repository provisions the AWS EKS cluster that LitmusChaos runs on, and declares the Argo CD applications deployed to it. It is not part of the Litmus chaos engineering product — for that, see [litmuschaos/litmus](https://github.com/litmuschaos/litmus).

> **Note:** changes merged to `master` are applied to live production infrastructure. See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## What This Repository Deploys

| Service | Host |
| --- | --- |
| Litmus documentation | `docs.litmuschaos.io` |
| Litmus v1 documentation | `v1-docs.litmuschaos.io` |
| ChaosHub (production) | `hub.litmuschaos.io` |
| ChaosHub (staging) | `staging-hub.litmuschaos.io` |
| Slack invite redirect | `slack.litmuschaos.io` |
| Argo CD | `argocd.litmuschaos.io` |

Supporting components on the cluster include nginx-ingress, cert-manager with Let's Encrypt, kube-prometheus-stack, Loki, and metrics-server.

## Layout

```
aws-infra/      Terraform for the production AWS account
k8s-infra/      Argo CD Applications and the Kustomize bases they deploy
docs/           Cluster setup documentation
```

### `aws-infra/`

Terraform that provisions the production cluster:

- `vpc.tf` — VPC `litmuschaos-production-vpc` (`172.31.0.0/16`) with public and private subnets across three `us-east-1` availability zones.
- `eks.tf` — EKS cluster `litmuschaos-production-k8s-cluster` with a `t3.large` worker group, autoscaling between 3 and 5 nodes on a 60% average CPU target.
- `variables.tf` — all tunable values, including region, cluster name, Kubernetes version, and node sizing.
- `providers.tf` — AWS and Kubernetes providers, plus the S3 backend holding remote state.

State is stored remotely in the `litmuschaos-production-terraform-state` S3 bucket, so you need credentials for the LitmusChaos production AWS account to run Terraform against it.

### `k8s-infra/`

Deployment is managed by Argo CD following a GitOps model. Each `Application` under `k8s-infra/argo-apps/` points back at this repository at `targetRevision: master`, with automated sync, self-heal, and prune enabled. In practice this means **merging a manifest change to `master` deploys it** — there is no separate deploy step.

- `argo-apps/litmuschaos-apps/` — the Litmus-owned services (docs, v1 docs, production and staging ChaosHub, preview).
- `argo-apps/misc-apps/` — cluster add-ons: nginx-ingress, cert-manager, the Slack redirect.
- `argo-apps/monitoring/` — kube-prometheus-stack, Loki, metrics-server.
- The sibling directories (`litmus-docs/`, `prod-hub-litmuschaos/`, `staging-hub-litmuschaos/`, `v1-litmus-docs/`, `slack-redirect/`, `misc-manifests/`) hold the Kustomize bases those applications render.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) — the AWS provider is pinned to `3.74.1`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), configured with a `default` profile that has access to the LitmusChaos production account
- [kubectl](https://kubernetes.io/docs/tasks/tools/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [Helm](https://helm.sh/docs/intro/install/), for the initial Argo CD installation

## Working With the Terraform

```bash
cd aws-infra

# Validate without touching remote state or credentials
terraform init -backend=false
terraform validate
terraform fmt -check -recursive

# Against the real backend
terraform init
terraform plan
```

Do not run `terraform apply` by hand. Applies are automated — see below.

## Automation

[`.github/workflows/deploy.yaml`](.github/workflows/deploy.yaml) runs on every push to `master`. When the push touches `aws-infra/**`, it configures AWS credentials from repository secrets and runs `terraform init`, `plan`, and `apply -auto-approve`. Changes under `k8s-infra/**` are picked up by Argo CD rather than by this workflow.

## Cluster Setup

[`docs/ARGOCD-SETUP.md`](docs/ARGOCD-SETUP.md) covers bootstrapping a cluster from scratch: installing Argo CD via Helm, retrieving the initial admin credentials, applying the Argo CD applications, and the ingress definitions for each hosted service.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All commits must be signed off under the [Developer Certificate of Origin](https://developercertificate.org/).

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md). Please do not open a public issue for security problems.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
