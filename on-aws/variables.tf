variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "instance_default_pubkey" {
  type = string
}

variable "bastion_ip_hostnum" {
  type    = number
  default = 10
}

variable "bastion_access_cidrs" {
  type = list(string)
}

variable "windows_ip_hostnum" {
  type    = number
  default = 11
}

variable "arc_data" {
  type = object({
    appId = string
    appSec = string
    resourceGroup = string
    tenantId = string
    location = string
    subscriptionId = string
  })
}
