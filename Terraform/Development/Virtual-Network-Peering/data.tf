data "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.location}-RG"
}