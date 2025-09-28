terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5"
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "lab" {
  name     = "HT-IENO-LAB-00XXX"
}

resource "azurerm_network_security_group" "lab_nsg" {
  name                = "tf-vm-lab-nsg"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "lab_nic_nsg" {
  network_interface_id      = azurerm_network_interface.lab_nic.id
  network_security_group_id = azurerm_network_security_group.lab_nsg.id
}


resource "azurerm_virtual_network" "lab_vnet" {
  name                = "tf-vm-lab-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "tf-vm-lab-subnet"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "lab_nic" {
  name                = "tf-vm-lab-nic"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                = "tf-vm-lab"
  resource_group_name = data.azurerm_resource_group.lab.name
  location            = data.azurerm_resource_group.lab.location
  size                = "Standard_B1s" 
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.lab_nic.id]

  admin_password = "Ma3reftx!" 
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"

  }
}
resource "azurerm_public_ip" "lab_pip" {
  name                = "tf-vm-lab-pip"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku = "Standard"
}
