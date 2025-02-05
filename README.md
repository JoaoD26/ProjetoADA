# ProjetoADA - Em andamento

## 1- Localizar client id, subnet id, URI do cofre

## 2- criar arquivo terraform.tfvars com variaveis:
- user_email
- user_subscription
- adm_password
- tenant_id
- secret
- subnet_id

## 3- comandos para fazer o deployment e testar:
- ### *Executar o Terraform*
- az login
- az account set --subscription {id subscription}
- terraform init
- terraform plan
- terraform apply

- ### *Configurar AKS*
- az aks get-credentials --resource-group rg-joaod-projeto --name aks-joaod-projeto
- kubectl get nodes

- ### *Implantar aplicação*
- kubectl create namespace app
- kubectl apply -f k8s-deploy.yaml -n app

- ### *Testar aplicação*
- kubectl get pods -n app
- http://127.0.0.1:8080

- ### *Testar conexão com banco de dados*
- kubectl exec -it $(kubectl get pods -l app=app -o jsonpath="{.items[0].metadata.name}" -n app) -- /bin/sh
