# 4. Static Website Hosting

Date: 2026-07-07

## Status

Accepted

## Context

The project needs a hosting service for a static website. Azure has multiple ways to do this, Azure Blob Storage through static website hosting feature, and Azure Static Web Apps service. 

## Decision

The static website will be hosted using Azure Blob Storage's static website hosting feature.

While Azure Static Web Apps bundles many related concerns together, like built-in CI/CD, custom domain and DNS handling, and staging environments for pull requests, it nullifies the goal of this project which is to gain hands-on experience on building each of these components individually.

## Consequences

\+ Requires manually building CI/CD pipeline for deployment which meets the project's learning goals
\+ Requires manually configuring DNS and HTTPS which meets the project's learning goals
\- More setup effort and configuration required
\- Setting up DNS and HTTPS requires additional service
