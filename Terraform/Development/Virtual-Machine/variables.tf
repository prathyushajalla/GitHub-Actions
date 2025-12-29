variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
  default = "Azure"
}

variable "admin_password" {
  type = string
  default = "Azure@123"
}

variable "vm_count" {
  type = number
}