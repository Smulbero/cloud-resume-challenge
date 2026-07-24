# 2. Repository Structure

Date: 2026-07-06

## Status

Accepted

## Context

The project spans multiple concerns, frontend, backend, infrastructure, and documentation inside a single repository. A clear, consistent directory structure is needed so each part of the project has a clear home, structure remains easy to navigate as the project grows, and the CI/CD pipeline can target specific folders.

## Decision

The repository will follow this structure:

```
root
├── .github/
│   └── workflows/
├── docs/
│   ├── adrs/
│   └── architecture/
├── backend/
│   ├── api/
│   └── tests/
├── frontend/
│   ├── js/
│   │   └── scripts.js
│   ├── css/
│   │   └── styles.css
│   └── index.html
├── infrastructure/
│   └── terraform/
│       ├── modules/
│       └── *.tf
├── .gitignore
└── README.md
```

Notes on specific folders:
- `docs/adrs` holds all Architecture Decision Records
- `docs/architecture` holds supporting architecture material such as 
  diagrams and images
- `infrastructure/terraform` keeps root-level `.tf` files directly in the 
  `terraform` folder

## Consequences

**Positive**
- Each concern has a predictable location
- CI/CD workflows can be scoped on specific folders

**Negative**
- If `docs/architecture` grows to include non-image content, its scope 
  may need to be revisited
