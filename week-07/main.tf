resource "azurerm_public_ip" "week7" {
  name                = "week7-public-ip"
  location            = azurerm_resource_group.week7.location
  resource_group_name = azurerm_resource_group.week7.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "week7" {
  name                = "week7-nic"
  location            = azurerm_resource_group.week7.location
  resource_group_name = azurerm_resource_group.week7.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.week7.id
  }
}

resource "azurerm_linux_virtual_machine" "week7" {
  name                = "week7-vm"
  location            = azurerm_resource_group.week7.location
  resource_group_name = azurerm_resource_group.week7.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.week7.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/week7_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }
}
