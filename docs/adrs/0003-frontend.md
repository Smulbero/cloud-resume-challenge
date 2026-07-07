# 3. Frontend

Date: 2026-07-06

## Status

Accepted

## Context

The goal of the project is to host a single static webpage on Azure Blob Storage with an increasing visitor counter as visitors visit the page. As part of the project, frontend side will be integrated into CI/CD pipeline.

The project doesn't focus on frontend architecture, more on cloud infrastructure, CI/CD, and deployment automation.

## Decision

The frontend will be built using plain HTML, CSS, and vanilla JavaScript, with no frontend framework.

React was considered for building the frontend, since it's popular frontend framework for structuring UI code. However, React requires a build step before output can be deployed which adds complexity to the CI/CD pipeline. 

Given the site will be a single page, the added complexity of a framework and build step is not justified.

## Consequences

\+ Deployment is a direct file sync to Blob Storage
\+ CI/CD pipeline stays simpler
\+ Fewer moving parts to debug while implementing cloud and CI/CD parts of the challenge
\- No component-based structure which may affect future UI complexity needs
\- If the site ever grows past the project needs, this decision may need to be revisited
