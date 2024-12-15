locals {
    private_network_security_group_name = "private-nsg-${random_id.RandomId.id}"
	storage_account_name = lower("storage${random_id.RandomId.id}")
    public_network_security_group_name = "public-nsg-${random_id.RandomId.id}"
    vnet_name = "vnet-${random_id.RandomId.id}"
   	public_subnet_name = "public-subnet-${random_id.RandomId.id}"
    private_subnet_name = "private-subnet-${random_id.RandomId.id}"
    public_http_security_rule_name = "http-rule-${random_id.RandomId.id}"
	public_https_security_rule_name = "https-rule-${random_id.RandomId.id}"
    public_ssh_security_rule_name = "ssh-rule-${random_id.RandomId.id}"
	dns_label = replace(lower("${local.instance_name}-dns"), "_", "-")
	enable_accelerated_networking = false
	eth0_ip_address = var.Eth0IpAddress
	eth0_name = "eth0-${random_id.RandomId.id}"
	eth0_public_ip_address = "eth0-public-ip-${random_id.RandomId.id}"
	eth1_ip_addresses = var.Eth1IpAddresses
	eth1_name = "eth1-${random_id.RandomId.id}"
	image_plan_id = var.ImageSku
	image_version = var.ImageVersion
	instance_id = var.InstanceId
	instance_name = "reg-vmone-01"
	marketplace_image_offer_id = var.MarketplaceImageOfferId
	marketplace_image_product_id = local.marketplace_image_offer_id
	marketplace_image_publisher_id = var.MarketplaceImagePublisherId
	vm_size = var.AgentVmSize
}