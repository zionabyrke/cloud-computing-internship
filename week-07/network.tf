resource "azurerm_resource_group" "week7" {
  name     = "week7-rg"
  location = "East Asia"
}

resource "azurerm_virtual_network" "week7" {
  name                = "week7-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.week7.location
  resource_group_name = azurerm_resource_group.week7.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "week7-subnet1"
  resource_group_name  = azurerm_resource_group.week7.name
  virtual_network_name = azurerm_virtual_network.week7.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "week7-subnet2"
  resource_group_name  = azurerm_resource_group.week7.name
  virtual_network_name = azurerm_virtual_network.week7.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "week7" {
  name                = "week7-nsg"
  location            = azurerm_resource_group.week7.location
  resource_group_name = azurerm_resource_group.week7.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "week7" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.week7.id
}
