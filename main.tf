#AKS
resource "azurerm_kubernetes_cluster" "aks_joaod_projeto" {
  name                = "aks-joaod-projeto"
  location            = "brazilsouth"
  resource_group_name = "rg-joaod-projeto"
  dns_prefix          = "aks-joaod-projeto-dns"
  kubernetes_version  = "1.30.7"

  default_node_pool {
    name            = "agentpool"
    node_count      = 1
    vm_size         = "Standard_D2as_v4"
    os_disk_size_gb = 128
  }

  identity {
    type = "SystemAssigned"
  }
}

#Key vault
resource "azurerm_key_vault" "kv_joaod_projeto" {
  name                = "kv-joaod-projeto"
  location            = "brazilsouth"
  resource_group_name = "rg-joaod-projeto"
  tenant_id           = var.tenant_id

  sku_name = "standard"
}

resource "azurerm_key_vault_secret" "secret_joaod_projeto" {
  name         = "db-connection-string"
  value        = var.secret
  key_vault_id = azurerm_key_vault.kv_joaod_projeto.id
}

#Database
resource "azurerm_mssql_server" "db_joaod_projeto" {
  name                         = "db-joaod-projeto-server"
  resource_group_name          = "rg-joaod-projeto"
  location                     = "brazilsouth"
  version                      = "12.0"
  administrator_login          = "admprojeto"
  administrator_login_password = var.adm_password
}

#managed identity
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-joaod-projeto-agentpool"
  location            = "brazilsouth"
  resource_group_name = "rg-joaod-projeto"
}

#kubernetes service account
resource "azurerm_federated_identity_credential" "aks_federation" {
  name                = "aks-federation"
  resource_group_name = "rg-joaod-projeto"
  parent_id           = azurerm_user_assigned_identity.aks_identity.id
  audience           = ["api://AzureADTokenExchange"]
  issuer             = azurerm_kubernetes_cluster.aks_joaod_projeto.oidc_issuer_url
  subject            = "system:serviceaccount:default:my-app-sa"
}


#managed identity -> federacao com k8s service account
resource "azurerm_role_assignment" "aks_contributor" {
  scope                = azurerm_kubernetes_cluster.aks_joaod_projeto.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
#configurar storage account no pod
resource "azurerm_storage_account" "storage_acc" {
  name                     = "saprojeto"
  resource_group_name      = "rg-joaod-projeto"
  location                 = "brazilsouth"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#adicionar annotation na service account


#Add Permissao de Admin AKS
resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.aks_joaod_projeto.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = var.username
}

#configurar o label do pod para user workload identity

#Add Permissao no Key vault para adiconar a secret
resource "azurerm_key_vault_access_policy" "aks_write_secret" {
  key_vault_id = azurerm_key_vault.kv_joaod_projeto.id
  tenant_id    = azurerm_user_assigned_identity.aks_identity.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_identity.principal_id

  secret_permissions = [
    "Get", "List", "Set"
  ]
}

#managed identity -> Permissao pra ler a secret
resource "azurerm_role_assignment" "kv_reader" {
  scope                = azurerm_key_vault.kv_joaod_projeto.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

#configurar o firewall no banco de dados -> aks subnet
resource "azurerm_mssql_virtual_network_rule" "db_aks_rule" {
  name      = "allow-aks"
  server_id = azurerm_mssql_server.db_joaod_projeto.id
  subnet_id = var.subnet_id
}

resource "azurerm_public_ip" "public_ip_joaod" {
  name                = "public-ip-joaod"
  location            = "brazilsouth"
  resource_group_name = "rg-joaod-projeto"
  allocation_method   = "Static"
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "CPU Usage Percentage - aks-joaod-projeto"
  resource_group_name = "rg-joaod-projeto"
  scopes              = [azurerm_kubernetes_cluster.aks_joaod_projeto.id]
  description         = "Alerta de uso de CPU para o AKS"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95
  }
}

resource "azurerm_key_vault_access_policy" "aks_kv_policy" {
  key_vault_id = azurerm_key_vault.kv_joaod_projeto.id
  tenant_id    = azurerm_user_assigned_identity.aks_identity.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv_joaod_projeto.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.username
}

