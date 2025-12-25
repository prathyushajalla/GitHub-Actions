module "vir_net" {
  source             = "../../Modules/Virtual-Network/"
  nsgname            = var.nsgname
  location           = data.azurerm_resource_group.RG.location
  rgname             = data.azurerm_resource_group.RG.name
  security_rule_name = var.security_rule_name
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_name        = var.subnet_name
  subnet_address     = var.subnet_address
  subnet_name1       = var.subnet_name1
  subnet_address1    = var.subnet_address1
}