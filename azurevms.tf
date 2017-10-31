provider "azurerm" {
    subscription_id = "e6b872d2-your-guid-here-8f5e03f556dc"
    client_id       = "08a5a73a-your-guid-here-627968832722"
    client_secret   = "your$ecret"
    tenant_id       = "a2b2d6bc-your-guid-here-f97a7ac416d7"
}

variable "confignode_count" {default = 1}

resource "azurerm_resource_group" "th-hosted" {
  name     = "accth-hostedrg"
  location = "West US 2"
}

resource "azurerm_virtual_network" "th-hosted" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.th-hosted.name}"
}

resource "azurerm_subnet" "th-hosted" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.th-hosted.name}"
  virtual_network_name = "${azurerm_virtual_network.th-hosted.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "th-hosted" {
  count                        = "${var.confignode_count}"
  name                         = "th-hosted-pip-${count.index}"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.th-hosted.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "th-hosted" {
  count               = "${var.confignode_count}"
  name                = "acctni-${count.index}"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.th-hosted.name}"

  ip_configuration {
    name                          = "th-hostedconfiguration1"
    subnet_id                     = "${azurerm_subnet.th-hosted.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.th-hosted.*.id, count.index)}"
  }
}

resource "azurerm_managed_disk" "th-hosted" {
  count                = "${var.confignode_count}"
  name                 = "datadisk_existing-${count.index}"
  location             = "West US 2"
  resource_group_name  = "${azurerm_resource_group.th-hosted.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "th-hosted" {
  count                 = "${var.confignode_count}"
  name                  = "thhostedvm-${count.index}"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.th-hosted.name}"
  network_interface_ids = ["${element(azurerm_network_interface.th-hosted.*.id, count.index)}"]  
  vm_size               = "Standard_DS1_v2"
  depends_on            = ["azurerm_managed_disk.th-hosted", "azurerm_network_interface.th-hosted"]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "datadisk_new-${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "datadisk_existing-${count.index}"
    managed_disk_id = "${element(azurerm_managed_disk.th-hosted.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "1023"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_extension" "th-hosted" {
  count                = "${var.confignode_count}"
  name                 = "hostname-${count.index}"
  location             = "West US 2"
  resource_group_name  = "${azurerm_resource_group.th-hosted.name}"
  virtual_machine_name = "thhostedvm-${count.index}"
  publisher            = "Chef.Bootstrap.WindowsAzure"
  type                 = "LinuxChefClient"
  type_handler_version = "1210.12"
  depends_on           = ["azurerm_virtual_machine.th-hosted"]

  settings = <<SETTINGS
    {
    "bootstrap_options": {
        "chef_node_name": "thhostedvm-${count.index}",
        "chef_server_url": "https://api.chef.io/organizations/[[YOUR HOSTED CHEF ORG]]",
        "validation_client_name": "[[YOUR VALIDATOR NAME]]"
    },
    "runlist": "recipe[starter::default]",
    "client_rb": "ssl_verify_mode :verify_none\ndata_collector.server_url \"https://[[YOUR AUTOMATE URL]]/data-collector/v0/\"\ndata_collector.token \"[[YOUR DATA COLLECTOR TOKEN]]\"",
    "validation_key_format": "plaintext",
    "chef_daemon_interval": "5",
    "daemon" : "service",
    "hints": {
        "vm_name": "thhostedvm-${count.index}"
    }
    }
    SETTINGS
    protected_settings = <<PROTECTEDSETTINGS
    {
    "validation_key": "-----BEGIN RSA PRIVATE KEY-----\n[[YOUR PRIVATE KEY\nWITH LINE ENDINGS\n]]-----END RSA PRIVATE KEY-----"
    }
    PROTECTEDSETTINGS

  tags {
    environment = "staging"
  }
}