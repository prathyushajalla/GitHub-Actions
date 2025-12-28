module "rg" {
  source = "../../Modules/Resource-Group/"

  env                = var.env
  location           = var.location
  vnet_address_space = var.vnet_address_space
}