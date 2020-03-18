data "terraform_remote_state" "base_env" {
  backend = "remote"

  config = {
    organization = "synaptic_racing"
    workspaces = {
      name = "${var.base-workspace}"
    }
  }
}

provider "azurerm" {
  version = "2.1.0"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  version             = "3.0.0"
  resource_group_name = data.terraform_remote_state.base_env.outputs.rg-name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
  enable_ssh_key      = false
  ssh_key             = null
  vm_size             = var.vm_size
	admin_password      = var.admin_password
}

module "network" {
  source              = "app.terraform.io/synaptic_racing/network/azurerm"
  version             = "3.0.1"
  resource_group_name = data.terraform_remote_state.base_env.outputs.rg-name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
}

output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}
