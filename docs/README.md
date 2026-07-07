# Architecture

## Architecture Decision Records

Architectural decision records are recorded to preserve context of architectural choices. These will be written in the format proposed in a blog post by Michael Nygard

Please see the [decisions directory](adrs/) for a list of all ADRs

### Tooling
[adr-tools](https://github.com/npryce/adr-tools) is used to help manage the records

Initialization
`adr init docs/adrs`

Record new decision
`adr new 'Decision to record'`

Please ensure that this tool is used at the **root** of the repository only