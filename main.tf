provider "azurerm" {
  version = "2.1.0"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "terraform_remote_state" "base_env" {
  backend = "remote"

  config = {
    organization = "synaptic_racing"
    workspaces = {
      name = "${var.base-workspace}"
    }
  }
}

resource "azurerm_app_service_plan" "slotDemo" {
    name                = "slotAppServicePlan"
    location            = data.terraform_remote_state.base_env.outputs.rg-location
    resource_group_name = data.terraform_remote_state.base_env.outputs.rg-name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "slotDemo" {
    name                = "slotAppService"
    location            = data.terraform_remote_state.base_env.outputs.rg-location
    resource_group_name = data.terraform_remote_state.base_env.outputs.rg-name
    app_service_plan_id = azurerm_app_service_plan.slotDemo.id
}

resource "azurerm_app_service_slot" "slotDemo" {
    name                = "slotAppServiceSlotOne"
    location            = data.terraform_remote_state.base_env.outputs.rg-location
    resource_group_name = data.terraform_remote_state.base_env.outputs.rg-location
    app_service_plan_id = azurerm_app_service_plan.slotDemo.id
    app_service_name    = azurerm_app_service.slotDemo.name
}