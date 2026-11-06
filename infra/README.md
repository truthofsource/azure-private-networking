# Sanitized network foundation

The spoke resources adapt the author's own operational Terraform module. Hub peering, the illustrative management-ingress NSG and default-Off endpoint are public reference additions. Example addresses and names are fictional.

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
```

The tests use a mock provider and do not create Azure resources. If you later commission a real lab, review the entire plan, subscription, identity, addresses, costs and cleanup first. This module does not deploy a database, storage account, firewall or application; the optional endpoint targets a separately managed existing service and existing linked DNS zone. Public ingress on that service is a separate control. Do not infer end-to-end network isolation from this foundation.
