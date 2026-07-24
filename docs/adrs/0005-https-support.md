# 5. HTTPS Support

Date: 2026-07-07

## Status

Accepted

## Context

The static website hosted on Azure Blob Storage needs HTTPS support for the custom domain. Azure has two services for this, Azure CDN, and Azure Front Door.

## Decision

The project will use Azure Front Door to provide HTTPS for the custom domain.

At time of the writing, Azure CDN is in the process of being retired by 09/2027[¹]. It will be replaced by the Azure Front Door service with the same capabilities as Azure CDN and with additional features.

[¹]: https://learn.microsoft.com/en-us/azure/frontdoor/front-door-cdn-comparison "Comparison between Azure Front Door and Azure Content Delivery Network"

## Consequences

**Positive**
- Project uses a currently supported, actively developed Azure Service
- Avoids a forced migration and reconfiguration later

**Negative**
- AFD has higher baseline running cost compared to ACDN, which had no minimum fee for low-usage scenarios
- Slightly more complex service to configure
