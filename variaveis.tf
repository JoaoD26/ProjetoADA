variable "username"{
    description = "Nome do usuário"
    type        = string
}

variable "user_email" {
    description = "Email do usuário"
    type        = string
}

variable "user_subscription" {
    description = "Assinatura do usuário"
    type        = string
}

variable "adm_password" {
    description = "Senha de adm do banco de dados"
    type        = string
}

variable "tenant_id" {
    description = "Id Chave Cofre"
    type        = string
}

variable "secret" {
    description = "Connection string do banco de dados"
    type        = string
}

variable "subnet_id" {
    description = "ID da subnet"
    type        = string
}

data "azurerm_client_config" "current" {}


data "azuread_user" "current_user" {
  user_principal_name = var.username
}

