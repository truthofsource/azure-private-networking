# Scaling, strengths and tradeoffs

**Terms used here:** Role-based access control gives people or services permissions according to their roles. A private endpoint gives a supported service an address on a private network; access permissions still apply.

## When the workload grows

Give each reusable module a clear job and pass in the settings for each environment. Check address ranges before adding networks. Shared applications can have their own network when that makes ownership or failure isolation clearer; they do not all need to run in the hub. Track name lookup, address use, connection limits, cost and recovery access. Add a shared outbound-traffic service only after its routes and reliability needs are understood.

## Design choices

| Choice | Strength, weakness and tradeoff |
| --- | --- |
| Private endpoint | Reduces public exposure and supports private routing. Adds endpoint-hour/data costs, DNS work and operational dependencies. |
| Shared hub | Centralizes DNS, observability and access paths. A shared failure or overly broad route can affect several workloads. |
| Identity plus network policy | Protects against more failure modes than either control alone. Both must be tested; a private endpoint does not replace RBAC. |
| Public service endpoint with controls | Can support managed callers without a private route. Requires explicit access restrictions, authentication and exposure review. |

## Operating measures

Measure throughput, oldest pending work, duplicate/rejected operations, failure stage and recovery duration. Tie alerts to an operator action. Do not infer service availability from an old successful import or infer delivery from provider acceptance.

Start with measured load and an explicit service objective. Increase concurrency only after checking provider quotas, database contention, per-person ordering and recovery behavior. Horizontal scaling requires a shared durable store; independent in-memory or SQLite processes are not a distributed coordination system.
