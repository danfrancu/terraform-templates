# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Create resource group for our testing
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "regression"
    Team = "IxVM"
  }
}

# Create Storage account where we'll keep the boot diagnostics
resource "azurerm_resource_group" "storage" {
  name     = var.storage_account_name
  location = var.location

  tags = {
    Environment = "regression"
    Team = "IxVM"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create a random number to be used in auto generated docs
resource "random_id" "RandomId" {
	byte_length = 4
}

resource "azurerm_virtual_network" "Vnet" {
	name = local.vnet_name
	location = var.location
	resource_group_name = var.resource_group_name
    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
	address_space = [ var.vnet_address_prefix ]
}

resource "azurerm_subnet" "PublicSubnet" {
	name = local.public_subnet_name
	resource_group_name = var.resource_group_name
	virtual_network_name = azurerm_virtual_network.Vnet.name
	address_prefixes = [ var.public_subnet_prefix ]
	depends_on = [
		azurerm_virtual_network.Vnet
	]
    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

resource "azurerm_subnet" "PrivateSubnet" {
	name = local.private_subnet_name
	resource_group_name = var.resource_group_name
	virtual_network_name = azurerm_virtual_network.Vnet.name
	address_prefixes = [ var.private_subnet_prefix ]
	depends_on = [
		azurerm_virtual_network.Vnet
	]
    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

resource "azurerm_network_security_group" "PublicNetworkSecurityGroup" {
	name = local.PublicNetworkSecurityGroupName
	location = var.location
	resource_group_name = azurerm_resource_group.rg.name

	security_rule {
		name = local.public_https_secupublic_https_security_rule_namerity_rule_name
		description = "Allow HTTPS"
		protocol = "Tcp"
		source_port_range = "*"
		destination_port_range = "443"
		destination_address_prefix = "*"
		access = "Allow"
		priority = 100
		direction = "Inbound"
		source_address_prefixes = var.public_security_rule_source_ip_prefixes
		destination_address_prefixes = []
	}
	security_rule {
		name = local.public_ssh_security_rule_name
		description = "Allow SSH"
		protocol = "Tcp"
		source_port_range = "*"
		destination_port_range = "22"
		destination_address_prefix = "*"
		access = "Allow"
		priority = 101
		direction = "Inbound"
		source_address_prefixes = var.public_security_rule_source_ip_prefixes
		destination_address_prefixes = []
	}
	security_rule {
		name = local.public_http_security_rule_name
		description = "Allow HTTP"
		protocol = "Tcp"
		source_port_range = "*"
		destination_port_range = "80"
		destination_address_prefix = "*"
		access = "Allow"
		priority = 102
		direction = "Inbound"
		source_address_prefixes = var.public_security_rule_source_ip_prefixes
		destination_address_prefixes = []
	}
    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
} 

resource "azurerm_subnet_network_security_group_association" "PublicNetworkSecurityGroup" {
	subnet_id = azurerm_subnet.PublicSubnet.id
	network_security_group_id = azurerm_network_security_group.PublicNetworkSecurityGroup.id
}

resource "azurerm_network_security_group" "PrivateNetworkSecurityGroup" {
	name = local.PrivateNetworkSecurityGroupName
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
}

resource "azurerm_subnet_network_security_group_association" "PrivateNetworkSecurityGroup" {
	subnet_id = azurerm_subnet.PrivateSubnet.id
	network_security_group_id = azurerm_network_security_group.PrivateNetworkSecurityGroup.id
}