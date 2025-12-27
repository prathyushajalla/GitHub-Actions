variable "rgname" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "rs_prefixes" {
  type = list(string)
}

variable "location" {
  type    = string
  default = "Central US"
}