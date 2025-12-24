terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
    backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate1766591150"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
    use_oidc             = true # Required since we're using OIDC in GitHub Actions
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "RG" {
  name     = var.rgname
  location = var.location
}