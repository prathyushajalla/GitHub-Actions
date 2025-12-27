module "route_server" {
  source      = "../../Modules/Route-Server/"
  vnetname    = var.vnet_name
  rgname      = var.rgname
  rs_prefixes = var.rs_prefixes
}