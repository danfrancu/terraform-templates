variable "location" {
	default = "westus2"
	description = "Location where resource group stored"
	type = string
}

variable "resource_group_name" {
  default = "ixvm-regression-terraform"
}

variable "storage_account_name" {
  default = "regression${random_id.RandomId.id}"
}

variable "vnet_address_prefix" {
	default = "10.0.0.0/16"
    description = "Address space of the Virtual Network"
	type = string
}

variable "public_subnet_prefix" {
	default = "10.0.1.0/24"
	description = "IP CIDR range allocated to the public subnet"
	type = string
}

variable "private_subnet_prefix" {
	default = "10.0.10.0/24"
	description = "IP CIDR range allocated to the private subnet"
	type = string
}

variable "public_security_rule_source_ip_prefixes" {
	description = "List of IP Addresses /32 or IP CIDR ranges connecting inbound to App"
	type = list(string)
}