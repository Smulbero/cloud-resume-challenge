# 10. Terraform Variable File Management

Date: 2026-09-22

## Status

Accepted

## Context

The project's Terraform configuration is parameterized through a single `.tfvars` file containing values for all root module variables.

The `checkov.yml` GitHub Actions workflow requires a generated `.tfplan` file to scan, which in turn requires these variable values to be available during the workflow run. The same issue raises when Github Actions workflow will be used to provision the infrastructure automatically.

Common guidance is that `.tfvars` files should never be committed to version control, since they typically mix configuration with secrets.

Auditing the file's contents showed that only the two Cloudflare values are actual credentials. The remainder is architectural configuration that are no different in sensitivity from the rest of this repository, which is already fully public by design.

Several approaches were considered for supplying these values to the CI/CD pipeline:

1. **Store the entire `.tfvars` file in a private location** (e.g., a separate Azure Storage container, fetched during the workflow using the same Azure credentials already used for the Terraform state backend). While this fully removes config from git, it does not meaningfully change the project's goal, which is to act as public portfolio. This process includes manual steps to keep the `tfvars` file updated in private location.
2. **Split values by sensitivity**: commit non-secret configuration directly to the repository as `terraform.tfvars` and inject the secrets via GitHub Actions repository secrets, exposed to Terraform as `TF_VAR_*` environment variables at runtime.

## Decision

Option 2 will be used.

- `terraform.tfvars`, containing all non-secret configuration, will be committed to the repository.
- Secret values will be stored as Github Actions repository secrets and suppliad to Terraform via `TF_VAR_*` environment variables in the workflow.
- Generated `.tfplan` files will not be uploaded as persistent GitHub Actions artifacts on this public repository, since plan files contain resolved variable values (including secrets) in recoverable form even though Terraform's CLI output redacts them. Plan generation and consumption (`checkov` scan) will stay within the same job.

## Consequences

**Positive**
- Cloning the repository and running `terraform plan` requires no separate authenticated fetch step, which keeps the project fully reproducible
- Configuration changes are tracked in the same commit history as the code that consumes them
- No new infrastructure, service, or credential surface is introduced to solve this problem
- Consistent with the project's goal of publishing its full architecture for portfolio purposes

**Negative**
- Future accidental secret commits are possible, therefore some additional guardrails might be needed to apply, such as `gitleaks`
- Maintaining infrastructure secrets in Github Actions repository secrets can be a hazzle