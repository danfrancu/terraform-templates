variable "location" {
	default = "eastus"
	description = "Location where resource group stored"
	type = string
}

variable "resource_group_name" {
    default = "ixvm-regression-terraform"
}

variable "vnet_address_prefix" {
	default = "10.0.0.0/16"
    description = "Address space of the Virtual Network"
	type = string
}

variable "public_subnet_prefix" {
	default = "10.0.0.0/24"
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
    default = ["213.249.122.234"]
}

variable "AgentVmSize" {
	default = "Standard_F8s_v2"
	description = "Category, series and instance specifications associated with the Agent VM"
	type = string
	validation {
		condition = contains([	"Standard_F4s_v2",	"Standard_F8s_v2",	"Standard_F16s_v2"
							], var.AgentVmSize)
		error_message = <<EOF
AgentVmSize must be one of the following sizes:
	Standard_F4s_v2, Standard_F8s_v2, Standard_F16s_v2
		EOF
	}
}

variable "SkipProviderRegistration" {
	default = false
	description = "Indicates whether or not to ignore registration of Azure Resource Providers due to insuffiencient permissions"
	type = bool
}

variable "SubscriptionId" {
	default = null
	description = "Id of subscription and underlying services used by the deployment"
	sensitive = true
	type = string
}

variable "TenantId" {
	default = null
	description  = "Id of an Azure Active Directory instance where one subscription may have multiple tenants"
	sensitive = true
	type = string
}

variable "ClientId" {
	default = null
	description = "Id of an application created in Azure Active Directory"
	sensitive = true
	type = string
}

variable "ClientSecret" {
	default = null
	description = "Authentication value of an application created in Azure Active Directory"
	sensitive = true
	type = string
}

variable "AdminUserName" {
	default = "regression"
	description = "Id of the VM administrator account"
	type = string
}

variable "AdminPassword" {
	default = "Regress!On"
	description = "Password of the VM administrator account"
    sensitive = true
	type = string
}

variable "DisablePasswordAuthentication" {
	default = false
	description = "Disable SSH password auth in favor of key-based auth"
	type = bool
}

variable "EnableIpForwarding" {
	default = true
	description = "Enables forwarding of network traffic to an address not assigned to VM"
	type = bool
}

variable "Eth0IpAddress" {
	default = "10.0.0.11"
	description = "Private ip address associated with the first network interface"
	type = string
}

variable "Eth1IpAddresses" {
	default = ["10.0.10.12", "10.0.10.13", "10.0.10.14", "10.0.10.15", "10.0.10.16", "10.0.10.17", "10.0.10.18", "10.0.10.19", "10.0.10.20", "10.0.10.21"]
	description = "Private ip addresses associated with the second network interface"
	type = list(string)
}

variable "Build" {
    default = "11.00.4444.155"
    description = "Build version of our VMONE (VIRTUAL TEST APPLIANCE)"
    type = string
}