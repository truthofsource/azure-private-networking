# Terraform infrastructure

Parameterized hub/spoke networking, peering configured in both directions, a delegated application subnet, a separate endpoint subnet, management-ingress restrictions and an opt-in endpoint for an existing service.

These configurations adapt the same resource boundaries used in the author's workforce/operations platform. Names and input examples are neutral; no environment state, backend, import block, secret or production identifier is included. Each folder is a standalone reference root, not a command to adopt an existing production resource into new state.

## Code map

| File | Purpose |
| --- | --- |
| [main.tf](main.tf) | Hub/spoke VNets, peering, subnet delegation, NSG and optional existing-service private endpoint. |
| [variables.tf](variables.tf) | Names, fictional address plan and reviewed service/DNS integration inputs. |
| [tests/foundation.tftest.hcl](tests/foundation.tftest.hcl) | Default-Off endpoint and required-target checks. |
| [versions.tf](versions.tf) | Exact provider versions; lock file records provider checksums. |
| [example inputs](example.tfvars.example) | Reviewable inputs with placeholders; never actual tenant values. |

## Validate locally without a cloud deployment

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
```

The `.tftest.hcl` files use mock providers and plan commands. They do not authenticate to Azure, create resources or mutate Entra. Provider initialization downloads provider packages; it is not an infrastructure deployment. No automatic Terraform apply is included in GitHub Actions. The existing workflow remains manual-only to avoid unnecessary Actions usage.

The `.tfvars.example` file is not loaded automatically. It contains placeholders and is not ready for a real plan. Leave real `.tfvars`, backend/state, saved plans and credentials outside Git. If you separately deploy a lab, review exact subscription/tenant, names, complete saved plan, permissions, network route, costs and cleanup first. Use a protected remote backend with Entra authentication; this public root deliberately supplies no organization backend.

## Integration boundaries

Application runtime, database/storage service, existing linked private DNS zone, DNS resolver, deployment/recovery callers and their identities are separate. Peering is not automatic routing through another connected network. The model in the local dashboard is not an Azure NSG probe.

## Security and activation

The optional endpoint stays off. Review address overlap, private-zone links, caller routes and service ingress before enabling it. The NSG blocks management ports; it does not define every application/service egress dependency or independently provide full microsegmentation.

## Cost, retention and cleanup

Peering traffic and optional endpoints can be billed. The module does not deploy a firewall, gateway or Bastion. No costs were incurred through Terraform apply during preparation.

Mock-test cleanup is entirely local. A real destroy is a separate reviewed action against the correct lab state; never run it against copied production state or shared resources. Payroll deletion protection in the identity example intentionally prevents a casual destroy of that group. Retire grants/trust and inventory retained recovery artifacts before removing a real lab.

## Strengths and tradeoffs

A shared hub gives common connectivity and DNS ownership. Each workload still needs a clear route and identity. Private endpoints reduce exposure but introduce DNS, cost and recovery dependencies.

## Resource inventory

| Terraform resource type | Local name | Definition |
| --- | --- | --- |
| `azurerm_resource_group` | `workload` | [main.tf](main.tf) |
| `azurerm_virtual_network` | `workload` | [main.tf](main.tf) |
| `azurerm_subnet` | `functions_integration` | [main.tf](main.tf) |
| `azurerm_subnet` | `private_endpoints` | [main.tf](main.tf) |
| `azurerm_virtual_network` | `hub` | [main.tf](main.tf) |
| `azurerm_virtual_network_peering` | `hub_to_spoke` | [main.tf](main.tf) |
| `azurerm_virtual_network_peering` | `spoke_to_hub` | [main.tf](main.tf) |
| `azurerm_network_security_group` | `application` | [main.tf](main.tf) |
| `azurerm_subnet_network_security_group_association` | `application` | [main.tf](main.tf) |
| `azurerm_private_endpoint` | `existing_service` | [main.tf](main.tf) |

## Official references

- [Terraform test command and mock providers](https://developer.hashicorp.com/terraform/cli/commands/test)
- [AzureRM provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Registry repository permissions](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions)

See [project architecture](../docs/ARCHITECTURE.md) and [validation evidence](../docs/VALIDATION.md) for the separate application/reference boundaries.
