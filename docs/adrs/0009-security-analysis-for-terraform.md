# 9. Security Analysis for Terraform

Date: 2026-07-26

## Status

Accepted

## Context

Terraform code defines cloud infrastructure declaratively, and misconfigurations are possible. These misconfiguration can introduce security related issues that aren't obvious from reading the code alone. Catching these issues before `terraform apply` is preferable to discovering them after resources are already deployed.

## Decision

The project will use `checkov` to scan Terraform code for security misconfigurations. 

Checkov is an open-source static analysis tool that scans IaC formats against a large set of built-in policies covering common issues such as unencrypted resources, overly permissive access, and publicly exposed services. It runs entirely against the code itself, without needing cloud credentials or a deployed environment.

## Consequences

**Positive**
- Security misconfigurations are caught before infrastructure is deployed, rather than discovered afterward
- Large set of predefined policies covering Azure resources, without needing to write custom rules upfront
- Can be integrated into CI/CD pipeline

**Negative**
- May produce false positives or flag checks not relevant to this project's scale, requiring individual checks to be explicitly skipped or suppressed inline
- Extra CI/CD pipeline step

## References

- [Checkov](https://www.checkov.io/)
- [Checkov Github Repository](https://github.com/bridgecrewio/checkov)