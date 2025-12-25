module "rg" {
  source = "../../Modules/Resource-Group/"

  rgname   = var.rgname
  location = var.location
}