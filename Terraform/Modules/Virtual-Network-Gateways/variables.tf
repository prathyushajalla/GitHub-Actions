variable "rgname" {}
variable "virtual_network_name" {}
variable "vnet_address_space" {
  type = string
}
variable "location" {}
variable "env" {}
variable "asn" {}
variable "hub_cidr"{
  type = string
  default = "10.0.0.0/16"
}