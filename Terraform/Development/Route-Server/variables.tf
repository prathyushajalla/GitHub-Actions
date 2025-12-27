variable "rgname" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "rs_prefixes" {
  type = list(string)
}

variable "hub_rs_pip_name" {
  type = string
}