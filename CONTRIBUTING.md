# Contributing to litmus-cd

Thanks for your interest in contributing! This repository holds the infrastructure and continuous delivery configuration that runs the LitmusChaos project's own services, so changes here affect live environments. Please read this guide before opening a pull request.

## Getting Started

### Ask Questions or Discuss Ideas

Join the community on [Slack](https://slack.litmuschaos.io) and post in **#litmus** for general questions or **#litmus-dev** for technical discussions.

### Report Issues or Propose Changes

Open a new [GitHub issue](https://github.com/litmuschaos/litmus-cd/issues/new) describing your request, bug, or proposal. For anything that changes production infrastructure, please open an issue and reach agreement with the maintainers before writing code.

## What Lives Here

| Directory | Contents |
| --- | --- |
| `aws-infra/` | Terraform for the AWS EKS cluster, VPC, and providers |
| `k8s-infra/` | Argo CD `Application` definitions and the Kustomize bases they point at |
| `docs/` | Setup documentation, including the Argo CD bootstrap guide |

See the [README](README.md) for a fuller description.

## Developer Certificate of Origin (DCO)

All contributions must be signed off with the **Developer Certificate of Origin**, confirming you have the legal right to submit your work. Add a line to every commit message:

```
Signed-off-by: Joe Smith <joe.smith@email.com>
```

To sign off automatically, set your git identity and use `git commit -s`:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git commit -s
```

Use your real name — no pseudonyms or anonymous commits. For full details, see the [DCO documentation](https://developercertificate.org/).

## Submitting a Pull Request

1. **Fork the repository** and create a feature branch from `master`.
2. **Make your change.** Keep pull requests focused on a single concern.
3. **Validate locally** before pushing — see below.
4. **Open the pull request** against `master`, describing what changed and why. Link the issue it addresses.
5. **Respond to review.** Every pull request is reviewed by one or more of the maintainers listed in [`.github/CODEOWNERS`](.github/CODEOWNERS).

## Validating Your Changes

Because this repository is applied to live clusters, please check your work before opening a pull request.

**Terraform changes** under `aws-infra/`:

```bash
cd aws-infra
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Include the relevant `terraform plan` output in your pull request description when changing cluster resources.

**Kubernetes manifests** under `k8s-infra/`:

```bash
# Render any Kustomize overlay you touched and confirm it builds
kustomize build k8s-infra/<directory>
```

Never commit secrets, `*.tfvars` files, kubeconfigs, or `terraform.tfstate`. These are excluded by [`.gitignore`](.gitignore), but double-check `git diff --staged` before committing.

## Code of Conduct

This project follows the [LitmusChaos Code of Conduct](https://github.com/litmuschaos/litmus/blob/master/CODE_OF_CONDUCT.md).
