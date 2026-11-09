# Operations and troubleshooting

**Terms used here:** A digest is a file or container fingerprint used to confirm the exact version. An artifact is a file produced for a release, such as an application ZIP or container image.

## Start and stop

Run unit tests, then start the loopback dashboard with `python -B -m lab serve`. Stop with Ctrl+C. Each demonstration uses disposable test-only state; running it twice does not send messages or change a cloud resource.

## Diagnose by failure stage

| Symptom | Check and next action |
| --- | --- |
| Private name resolves publicly | Check the actual private DNS zone name, record, VNet link and resolver path from that caller. A successful lookup on an engineer laptop is not proof for a hosted runner. |
| Private IP but connection fails | Check route, subnet policy, NSG, port, service ingress and identity separately. |
| Deployment broke after closure | Verify the runner has a supported private route and DNS. Do not permanently open storage or SQL to all Azure services as a shortcut. |
| Terraform proposes unexpected changes | Stop and compare state, provider version and environment inputs. Never apply a broad plan solely to create one endpoint. |

## Cleanup

Default demos use managed temporary directories and close their own database handles. Do not run blanket recursive cleanup against a shared checkout. Inspect `git status --short --ignored`, stop the local server and remove only artifacts you created. Cloud resource cleanup is a separate reviewed operation and is never triggered by this repository's CI.

## Evidence to keep

Retain source commit, test command/exit status, tool versions and safe error stage. For a real release, also retain exact package/image digest and the restored operating state. Do not retain credentials, bearer tokens or employee data in public artifacts.

## DNS walkthrough

[Configure and verify Azure Private DNS](DNS-WALKTHROUGH.md) follows the actual zone/link/endpoint pattern, with read-only checks and a dated configuration inventory. A private DNS record, a working network connection and authorized data access require separate evidence.
