variable "subscription_id" {
  type = string
  default = "4dc63939-80f6-4f50-bd19-bc605cf2786d"
}

variable "resource_group_name" {
  type    = string
  default = "rg-vmataloni"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "acr_name" {
  type    = string
  default = "acrvmataloni"
}

variable "acr_server" {
  type    = string
  default = "acrvmataloni.azurecr.io"
}
