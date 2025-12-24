module "rg" {
  source  = "../Modules/Resource-Group/"

  name     = var.rgname
  location = var.location
}