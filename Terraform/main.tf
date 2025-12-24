terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  # Terraform requires this block to handle specific behaviors for Azure resources (like resource deletion policies).
  # Without it, the provider cannot initialize properly during the planning phase
  features {}
}

resource "azurerm_resource_group" "Test-RG" {
  name     = "Test-Resource-Group"
  location = "East US"
}