mock_provider "azurerm" {}
variables {
  location                          = "eastus2"
  resource_group_name               = "rg-example-network"
  virtual_network_name              = "vnet-example-workload"
  address_space                     = ["10.40.0.0/16"]
  functions_subnet_name             = "application"
  functions_subnet_prefixes         = ["10.40.1.0/24"]
  private_endpoints_subnet_name     = "endpoints"
  private_endpoints_subnet_prefixes = ["10.40.2.0/24"]
  tags                              = { project = "network-reference", environment = "lab" }
}
run "foundation_has_no_endpoint_by_default" {
  command = plan
  assert {
    condition     = length(azurerm_private_endpoint.existing_service) == 0
    error_message = "A private endpoint must remain opt-in."
  }
  assert {
    condition     = azurerm_subnet.functions_integration.address_prefixes == tolist(["10.40.1.0/24"])
    error_message = "Application subnet changed."
  }
}
run "endpoint_requires_reviewed_target" {
  command = plan
  variables { enable_private_endpoint = true }
  expect_failures = [azurerm_private_endpoint.existing_service[0]]
}
