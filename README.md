# ProjetoADA - Não concluído
## Problemas Encontrados:
- Problemas de conexão com a Key Vault
- Problemas de permissão do AKS e do MI
- Erro de configuração do firewall

  Infelizmente o projeto começou a acumular muitos erros e não consegui encontrar tempo livre o bastante para lidar com todos

# Passo a passo planejado:

## 1- criar arquivo terraform.tfvars com variaveis:
- user_email
- user_subscription
- adm_password
- tenant_id
- secret
- subnet_id

## 2- Comandos para fazer o deployment e testar:
- ### *Executar o Terraform*
```BASH
- az login
- az account set --subscription (id da susbcription)
- terraform init
- terraform plan
- terraform apply
```

- ### *Configurar AKS*
```BASH
- az aks get-credentials --resource-group rg-joaod-projeto --name aks-joaod-projeto
- kubectl get nodes
```
- ### *Implantar aplicação*
```BASH
- kubectl create namespace app
- kubectl apply -f k8s-deploy.yaml -n app
```
- ### *Testar aplicação*
```BASH
- kubectl get pods -n app
- http://127.0.0.1:8080
```
