moved {
  from = module.rg.azurerm_resource_group.rg
  to   = data.azurerm_resource_group.rg
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate1766591150"
    container_name       = "terraform-state"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}