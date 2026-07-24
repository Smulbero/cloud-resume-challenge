# 6. Database for Visitor Counter

Date: 2026-07-18

## Status

Accepted

## Context

The project needs a database to store a number value representing the number of visitors to the webpage. The value is expected to be stored as a key/value pair. Traffic is unpredictable, and costs should be minimized.

## Decision

Azure Cosmos DB will be used in serverless mode, which bills by per-request-unit (RU) consumption. The Cosmos DB Table API will be used as it offers simple key/value model which is suitable for this project. Cosmos DB's Table API also natively supports the simple read and write operations needed for this key/value access pattern.

While Azure SQL Database in serverless mode could also be used, it does not bill per RU. The service pauses after a period of inactivity and has a cold start on resume, meaning responses can be noticeably slow for the
first request after inactivity. It would also require self-managed connection/query logic, rather than Cosmos DB's native Function bindings.

## Consequences

**Positive**
- Database costs are minimized, billed based on request-units consumed
- No self-managed connection/query logic needed
- Avoids the cold-start latency that Azure SQL serverless would introduce 
  for infrequent visitors

**Negative**
- Data model is quite simple, and if the project grows past the initial 
  goal post, refactoring might be needed
