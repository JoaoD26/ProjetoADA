provider "azurerm" {
  features {
  }
  resource_provider_registrations = "none"
  subscription_id                 = var.user_subscription
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
}
