# Cloud Resume Challenge

> My take on the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) - a personal resume website hosted on Azure, with a serverless visitor counter, built and deployed through automation tools such as Terraform..
 
**🔗 Live site:** [crc.smulbero.com](https://crc.smulbero.com/)

---

## Table of Content

- [Project Summary](#project-summary)
- [Project Goals](#project-goals)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Project To-Do's](#project-to-dos)

---

## Project Summary

This project builds and deploys a personal resume as a static website, hosted on Azure. The page includes a visitor counter: every time someone loads the page, a serverless backend increments a count stored in a database and returns it to be displayed on the page.
 
---

## Project Goals
 
- [x] Deploy a static resume website to the cloud
- [x] Implement a working, persistent visitor counter
- [x] Provision all infrastructure using Terraform (no manual/portal setup)
- [ ] Automate frontend and backend deployment via CI/CD
- [x] Document architectural decisions as they're made (see [ADRs](docs/adrs/))
- [ ] Apply basic security scanning to infrastructure code
- [x] Configure a custom domain with HTTPS

---

## Architecture

*Architecture diagrams and such yet to be made*

---

## Tech Stack
 
| Layer                     | Technology                                  | 
|:-                         |:-                                           |
| Frontend                  | HTML, CSS, vanilla JavaScript               | 
| Static hosting            | Azure Blob Storage (static website)         |
| CDN / HTTPS               | Azure Front Door                            | 
| DNS                       | Cloudflare                                  |
| Backend API               | Azure Functions (Python, Flex Consumption)  |
| Database                  | Azure Cosmos DB (Table API, serverless)     | 
| Backend to DB auth        | Managed Identity                            |
| Infrastructure as Code    | Terraform                                   | 
| IaC documentation         | terraform-docs                              | 
| IaC security scanning     | Checkov                                     | 
| CI/CD                     | GitHub Actions                              | 
 
---

## Repository Structure
 
```
root
├── .github/workflows/     
├── docs/
│   ├── adrs/               
│   └── architecture/       
├── backend/
│   ├── api/     
│   └── tests/   
├── frontend/
│   ├── js/
│   ├── css/
│   └── index.html
├── infrastructure/
│   └── terraform/
│       ├── modules/
│       └── *.tf
├── .gitignore
└── README.md
```

---

## Project To-Do's
 
- [ ] Create architecture diagram(s) and add to `docs/architecture/`
- [ ] Set up CI/CD pipeline for frontend
- [ ] Set up CI/CD pipeline for backend
- [ ] Add Terraform plan/apply pipeline (with Checkov scan step)
- [ ] Add automated tests for the visitor-count Function
- [ ] Automate Cosmos DB Table RBAC role assignment (currently manual — see [docs/cosmos-table-rbac.md](docs/cosmos-table-rbac.md))

