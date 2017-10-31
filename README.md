# To Stand Up

* Spin up marketplace Chef Automate instance in Azure
    * Note your automate URL
    * Collect your data collector token
* Update azurevms.tf
    * with your azure credentials
    ```
    provider "azurerm" {
        subscription_id = "e6b872d2-your-guid-here-8f5e03f556dc"
        client_id       = "08a5a73a-your-guid-here-627968832722"
        client_secret   = "your$ecret"
        tenant_id       = "a2b2d6bc-your-guid-here-f97a7ac416d7"
    }
    ```
    * with your client credentials
    ```
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
    ```
    * Update count variable to desired number of VMs variable "confignode_count" {default = 1}
* Upload/ Install cis-ubuntu16.04lts-level1-server on your automate server
* Update chef-repo with your keys / chef org/ automate server details
* Update starter cookbook attributes with your CIS profile for cis-ubuntu16.04lts-level1-server
* Upload starter cookbook to your hosted Chef org
* run `terraform apply`