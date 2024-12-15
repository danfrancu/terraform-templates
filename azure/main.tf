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
resource "azurerm_storage_account" "storage" {
    name = local.storage_account_name
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "GRS"

	depends_on = [
		azurerm_resource_group.rg
	]

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

# Create a random number to be used in auto generated docs
resource "random_id" "RandomId" {
	byte_length = 4
}

# Creating the Virtual Network used for testing 
resource "azurerm_virtual_network" "Vnet" {
	name = local.vnet_name
	location = var.location
	resource_group_name = var.resource_group_name
	address_space = [ var.vnet_address_prefix ]

	depends_on = [
		azurerm_resource_group.rg
	]

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

# Creating the public subnet used for VM management
resource "azurerm_subnet" "PublicSubnet" {
	name = local.public_subnet_name
	resource_group_name = var.resource_group_name
	virtual_network_name = azurerm_virtual_network.Vnet.name
	address_prefixes = [ var.public_subnet_prefix ]
	depends_on = [
		azurerm_virtual_network.Vnet
	]
}

# Create the private subnet that is being used for testing only
resource "azurerm_subnet" "PrivateSubnet" {
	name = local.private_subnet_name
	resource_group_name = var.resource_group_name
	virtual_network_name = azurerm_virtual_network.Vnet.name
	address_prefixes = [ var.private_subnet_prefix ]
	depends_on = [
		azurerm_virtual_network.Vnet
	]
}

# Creating the public security group. This has only SSH, HTTP and HTTPS opened. 
resource "azurerm_network_security_group" "PublicNetworkSecurityGroup" {
	name = local.public_network_security_group_name
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	security_rule {
		name = local.public_https_security_rule_name
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

    depends_on = [
		azurerm_virtual_network.Vnet,
        azurerm_subnet.PublicSubnet
	]

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
} 

# Associating the public subnet to the public security group
resource "azurerm_subnet_network_security_group_association" "PublicNetworkSecurityGroup" {
	subnet_id = azurerm_subnet.PublicSubnet.id
	network_security_group_id = azurerm_network_security_group.PublicNetworkSecurityGroup.id
}

# Creating the private network security group. This has all rules open for traffic to flow
resource "azurerm_network_security_group" "PrivateNetworkSecurityGroup" {
	name = local.private_network_security_group_name
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

    depends_on = [
		azurerm_virtual_network.Vnet,
        azurerm_subnet.PrivateSubnet
	]

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

# Associating the private subnet to the private security group
resource "azurerm_subnet_network_security_group_association" "PrivateNetworkSecurityGroup" {
	subnet_id = azurerm_subnet.PrivateSubnet.id
	network_security_group_id = azurerm_network_security_group.PrivateNetworkSecurityGroup.id
}

# Search for the image based on the name that we're receiving and returning the ID
data "azurerm_image" "search" {
	name                = "Ixia_Cloud_Test_Appliance_${var.Build}"
	resource_group_name = "ixvm-builds"
}

# Creating an instance 
resource "azurerm_linux_virtual_machine" "Instance" {
	name = local.instance_name
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	size = local.vm_size
	source_image_id = data.azurerm_image.search.id
	os_disk {
		caching = "ReadWrite"
		storage_account_type = "Standard_LRS"
	}

	computer_name = replace(local.instance_name, "_", "-")
	admin_username = var.AdminUserName
    admin_password = var.AdminPassword
	disable_password_authentication = var.DisablePasswordAuthentication

	network_interface_ids = [
		azurerm_network_interface.Eth0.id,
		azurerm_network_interface.Eth1.id
	]
	boot_diagnostics {}
	depends_on = [
		azurerm_network_interface.Eth0,
		azurerm_network_interface.Eth1
	]
	timeouts {
		create = "9m"
		delete = "10m"
	}

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }
}

# Create eth0 interface for our VM
resource "azurerm_network_interface" "Eth0" {
	name = local.eth0_name
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	ip_configuration {
		name = "ipconfig1"
		private_ip_address = local.eth0_ip_address
		private_ip_address_allocation = "Static"
		public_ip_address_id = azurerm_public_ip.Eth0PublicIpAddress.id
		subnet_id = azurerm_subnet.PublicSubnet.id
		primary = "true"
		private_ip_address_version = "IPv4"
	}
	dns_servers = []
	enable_accelerated_networking = local.enable_accelerated_networking
	enable_ip_forwarding = var.EnableIpForwarding
	depends_on = [
		azurerm_public_ip.Eth0PublicIpAddress
	]

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }    
}

# Create eth1 interface for our VM
resource "azurerm_network_interface" "Eth1" {
	name = local.eth1_name
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	ip_configuration {
		name = "ipconfig1"
		private_ip_address = local.eth1_ip_addresses[0]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "true"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig2"
		private_ip_address = local.eth1_ip_addresses[1]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig3"
		private_ip_address = local.eth1_ip_addresses[2]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig4"
		private_ip_address = local.eth1_ip_addresses[3]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig5"
		private_ip_address = local.eth1_ip_addresses[4]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig6"
		private_ip_address = local.eth1_ip_addresses[5]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig7"
		private_ip_address = local.eth1_ip_addresses[6]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig8"
		private_ip_address = local.eth1_ip_addresses[7]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfig9"
		private_ip_address = local.eth1_ip_addresses[8]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	ip_configuration {
		name = "ipconfigA"
		private_ip_address = local.eth1_ip_addresses[9]
		private_ip_address_allocation = "Static"
		subnet_id = azurerm_subnet.PrivateSubnet.id
		primary = "false"
		private_ip_address_version = "IPv4"
	}
	dns_servers = []
	enable_accelerated_networking = local.enable_accelerated_networking
	enable_ip_forwarding = var.EnableIpForwarding

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }    
}

# Create eth0 public IP address
resource "azurerm_public_ip" "Eth0PublicIpAddress" {
	name = local.eth0_public_ip_address
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	ip_version = "IPv4"
	allocation_method = "Static"
	idle_timeout_in_minutes = 4
	domain_name_label = local.dns_label

    tags = {
        Environment = "regression"
        Team = "IxVM"
    }    
}