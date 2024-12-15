locals {
    PrivateNetworkSecurityGroupName = "${local.Preamble}-private-nsg"
    vnet_name = "${random_id.RandomId.id}-vnet"
   	public_subnet_name = "public-subnet-${random_id.RandomId.id}"
    private_subnet_name = "private-subnet-${random_id.RandomId.id}"
    public_http_security_rule_name = "http-rule-${random_id.RandomId.id}"
	public_https_security_rule_name = "https-rule-${random_id.RandomId.id}"
    public_ssh_security_rule_name = "ssh-rule-${random_id.RandomId.id}"
}