resource "azurerm_resource_group" "workload" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "workload" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location

  address_space = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "functions_integration" {
  name                 = var.functions_subnet_name
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name

  address_prefixes  = var.functions_subnet_prefixes
  service_endpoints = var.functions_subnet_service_endpoints

  delegation {
    name = "delegation-functions-flex-consumption"

    service_delegation {
      name = "Microsoft.App/environments"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name

  address_prefixes = var.private_endpoints_subnet_prefixes
}


resource "azurerm_virtual_network" "hub" {
  name                = "vnet-example-hub"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  address_space       = [var.hub_prefix]
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-workload"
  resource_group_name          = azurerm_resource_group.workload.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.workload.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "workload-to-hub"
  resource_group_name          = azurerm_resource_group.workload.name
  virtual_network_name         = azurerm_virtual_network.workload.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
}

resource "azurerm_network_security_group" "application" {
  name                = "nsg-example-application"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = var.tags
  security_rule {
    name                       = "deny-management-ingress"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.functions_integration.id
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_private_endpoint" "existing_service" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-example-service"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags
  private_service_connection {
    name                           = "existing-service"
    private_connection_resource_id = var.existing_service_id
    subresource_names              = [var.service_group_id]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "existing-private-zone"
    private_dns_zone_ids = [var.existing_private_dns_zone_id]
  }
  lifecycle {
    precondition {
      condition     = var.existing_service_id != "" && var.existing_private_dns_zone_id != "" && var.service_group_id != ""
      error_message = "Provide reviewed service, group and linked private DNS zone IDs before enabling an endpoint."
    }
  }
}

output "private_endpoint_enabled" {
  value = var.enable_private_endpoint
}
output "workload_vnet_id" {
  value = azurerm_virtual_network.workload.id
}
