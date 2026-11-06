# Secure Cloud Networking & Private Access

**Keep a public user experience while controlling the private data path.**

![Overview of the working local demonstration](docs/images/01-overview.png)

## Business scenario

A browser-based operations platform needed reachable sign-in and application pages while its database and employee documents required tighter network and identity boundaries. Deployment and recovery callers also needed a documented route.

**Business goal:** Reduce exposed data paths without breaking staff access, deployment, monitoring or recovery. Make DNS and caller checks explicit before closing a public endpoint.

## Engineering context

This project distills work I designed and implemented for an Azure-based workforce and operations platform. The organization, people, cloud resource names and records have been anonymized. The public code extracts selected decisions into a runnable reference; it is not a copy of the private production system.

- Organized shared services and workload networks using parameterized Terraform modules rather than duplicating each environment.
- Used a dedicated application-integration subnet and a separate private-endpoint subnet, with resource ownership, naming and tags supplied as inputs.
- Operated a protected SQL path with separately controlled, time-limited inspection procedures and explicit restoration checks.
- Reviewed storage/vault private-path proposals against actual deployment callers, DNS resolution and cost; did not present every proposed private endpoint as deployed.

The screenshots are captured from this repository's working **local demonstration with fictional data**. They are not cloud-portal screenshots or claims that a visitor has provisioned these resources. [Evidence and scope](docs/VALIDATION.md) distinguishes implemented platform patterns, local tests and cloud work not commissioned here.

## Architecture

```mermaid
flowchart LR
  Internet --> Portal[Public application and identity]
  Hub[Shared-services hub] <-->|VNet peering| Spoke[Workload spoke]
  Portal --> App[Application integration subnet]
  Spoke --> App
  App -->|HTTPS and identity| PE[Optional private endpoint]
  DNS[Private DNS zone and VNet link] --> PE
  PE --> Store[Existing private data service]
  Runner[Reviewed deployment caller] -.-> Hub
```

## Run it

Requires Python 3.12 or newer. The identity example also installs its pinned cryptography dependency. Run inside a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -B -m unittest discover -s tests -v
python -B -m lab demo
python -B -m lab serve --port 8011
```

On Windows, use `.venv\Scripts\Activate.ps1` instead of the `source` command, or run `.venv\Scripts\python.exe` directly. Open [the local workbench](http://127.0.0.1:8011), choose **Run demonstration**, then review **Validation** and **Evidence**. Stop with Ctrl+C. No cloud login, employee data or paid API request is required.

## Validation and failure handling

![Positive and negative checks from the local execution](docs/images/02-validation.png)

Expected security denials count as successful negative tests. The implementation walkthrough explains what each check demonstrates and where the hosted-system boundary begins.

| Read next | Purpose |
| --- | --- |
| [Implementation walkthrough](docs/WALKTHROUGH.md) | Follow the code, business decision and failure case |
| [Architecture](docs/ARCHITECTURE.md) | Understand trust boundaries and cloud integration |
| [Validation evidence](docs/VALIDATION.md) | See actual local results and untested boundaries |
| [Security and privacy](SECURITY.md) | Review permissions, secrets and publication controls |
| [Operations and troubleshooting](docs/OPERATIONS.md) | Diagnose failures and clean up safely |
| [Scaling and tradeoffs](docs/SCALING.md) | Decide when to change the design |
| [Sources and presentation credits](docs/REFERENCES.md) | Technical references and README inspiration |

## Repository map

```text
lab/                 Working reference implementation and loopback dashboard
tests/               Positive, negative and recovery cases
docs/                Architecture, walkthrough, evidence and operating guide
.github/workflows/   Manual-only contract validation; no cloud deployment
```

## Cost and cleanup

The default local demo creates only temporary local state and makes no paid calls. Cloud examples are separate opt-in source and can create billable resources if an operator applies them. No automated deployment or destruction is configured. Use `git status --short --ignored` before cleanup; remove only your own `.venv` or disposable lab output. Never copy real state files, tokens or employee documents into this repository.
