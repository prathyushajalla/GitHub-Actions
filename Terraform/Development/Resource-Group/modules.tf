module "rg" {
  source = "../../Modules/Resource-Group/"

  rgname   = var.rgname
  location = var.location
}

providers = {
    azurerm = azurerm # This passes the parent provider to the child
  }