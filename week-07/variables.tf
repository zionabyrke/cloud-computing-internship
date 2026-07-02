variable "vm_size" {
  description = "Azure VM size"
  default     = "Standard_B1s"
}

variable "image_offer" {
  description = "OS image offer"
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "OS image SKU"
  default     = "22_04-lts"
}

variable "admin_username" {
  description = "VM admin username"
  default     = "azureuser"
}
