# 🚀 Deploy da Aplicação Flask no EKS

## 📋 Pré-requisitos

1. **Cluster EKS** já criado e funcionando ✅
2. **kubectl** instalado e configurado
3. **Docker** instalado
4. **Conta no Docker Hub**

## 🔧 Configurações Necessárias

### 1. **Atualizar o Docker Hub Username**
Edite os seguintes arquivos e substitua `SEU_USUARIO_DOCKERHUB` pelo seu usuário do Docker Hub:
- `k8s-manifests/04-deployment.yaml` (linha 15)
- `build-and-deploy.sh` (linha 4)

### 2. **Instalar o AWS Load Balancer Controller**
```bash
# Adicionar o repositório Helm
helm repo add eks https://aws.github.io/eks-charts

# Instalar o AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=flask-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

## 🚀 Passos para o Deploy

### 1. **Aplicar os Manifests Kubernetes**
```bash
# Aplicar na ordem correta
kubectl apply -f k8s-manifests/01-namespace.yaml
kubectl apply -f k8s-manifests/02-configmap.yaml
kubectl apply -f k8s-manifests/03-secret.yaml
kubectl apply -f k8s-manifests/04-deployment.yaml
kubectl apply -f k8s-manifests/05-service.yaml
kubectl apply -f k8s-manifests/06-ingress.yaml
```

### 2. **Build e Push da Imagem Docker**
```bash
# Executar o script de build e deploy
chmod +x build-and-deploy.sh
./build-and-deploy.sh
```

### 3. **Verificar o Status**
```bash
# Verificar pods
kubectl get pods -n flask-app

# Verificar services
kubectl get svc -n flask-app

# Verificar ingress
kubectl get ingress -n flask-app

# Verificar logs
kubectl logs -f deployment/flask-app -n flask-app
```

## 🌐 Acesso à Aplicação

Após o deploy, a aplicação estará disponível através do Load Balancer criado pelo Ingress. O endereço será mostrado no comando:
```bash
kubectl get ingress flask-app-ingress -n flask-app
```

## 🔍 Troubleshooting

### Verificar se os pods estão rodando:
```bash
kubectl describe pods -n flask-app
```

### Verificar logs dos pods:
```bash
kubectl logs <pod-name> -n flask-app
```

### Verificar eventos do namespace:
```bash
kubectl get events -n flask-app
```

## 📊 Monitoramento

### Verificar recursos utilizados:
```bash
kubectl top pods -n flask-app
kubectl top nodes
```

### Verificar endpoints:
```bash
kubectl get endpoints -n flask-app
``` 