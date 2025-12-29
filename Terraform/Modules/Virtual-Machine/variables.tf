variable "env" {}
variable "location" {}
variable "rgname" {}
variable "virtual_network_name" {}
variable "vnet_address_space" {
  type = string
}
variable "admin_username" {}
variable "admin_password" {}
variable "network_security_group_id" {}
variable "existing_resource_group_name" {}
variable "existing_security_group_name" {}