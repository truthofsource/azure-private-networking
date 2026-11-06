variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "functions_subnet_prefixes" {
  type = list(string)
}

variable "functions_subnet_service_endpoints" {
  type    = list(string)
  default = []
}

variable "private_endpoints_subnet_prefixes" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "functions_subnet_name" {
  type = string
}

variable "private_endpoints_subnet_name" {
  type = string
}

variable "hub_prefix" {
  type    = string
  default = "10.20.0.0/16"
}
variable "enable_private_endpoint" {
  type    = bool
  default = false
}
variable "existing_service_id" {
  type    = string
  default = ""
}
variable "existing_private_dns_zone_id" {
  type    = string
  default = ""
}
variable "service_group_id" {
  type    = string
  default = ""
}
