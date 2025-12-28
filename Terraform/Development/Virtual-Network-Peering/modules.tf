module "vir_net" {
  source             = "../../Modules/Virtual-Network-Peering/"
  location           = data.azurerm_resource_group.rg.location
  rgname             = data.azurerm_resource_group.rg.name
  env                = var.env
  vnet_address_space = var.vnet_address_space
}