data "azuread_user" "current_user" {
  user_principal_name = "seu.email@dominio.com"
}

variable "user_object_id" {
  default = data.azuread_user.current_user.id
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