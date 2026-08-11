# 8. Documenting Terraform

Date: 2026-07-26

## Status

Accepted

## Context

Terraform code needs to be documented so that inputs, outputs, providers, and resources for each module and root configuration are clear to anyone reading or maintaining the code, without needing to read through every `.tf` file manually.

## Decision

The project will use `terraform-docs` to automatically generate documentation from the Terraform code itself.

`terraform-docs` reads variables, outputs, providers, and resources directly from `.tf` files and generates documentation. This keeps documentation close to the code it describes and reduces the risk of documentation drifting out of sync with manually-written alternatives.

## Consequences

**Positive**
- Documentation stays accurate, since it's generated directly from the Terraform source rather than written and maintained by hand
- Consistent format across all modules and root configurations
- Can be integrated into CI/CD pipeline

**Negative**
- Only documents what Terraform itself exposes, e.g. variables, outputs, providers, resources
- Extra CI/CD pipeline step

## References

- [terraform-docs](https://terraform-docs.io/user-guide/introduction/)
