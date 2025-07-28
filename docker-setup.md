# Configuração Docker Hub e EKS

## 1. Configuração do Docker Hub

### 1.1 Criar conta no Docker Hub
1. Acesse https://hub.docker.com
2. Crie uma conta gratuita
3. Crie um repositório para suas imagens

### 1.2 Login no Docker Hub
```bash
docker login
```

## 2. Criando Imagens Docker para as Aplicações

### 2.1 Exemplo de Dockerfile para aplicação Flask

Crie um arquivo `Dockerfile` na raiz do seu projeto Flask:

```dockerfile
# Usar imagem base do Python
FROM python:3.9-slim

# Definir diretório de trabalho
WORKDIR /app

# Copiar requirements.txt
COPY requirements.txt .

# Instalar dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código da aplicação
COPY . .

# Expor porta
EXPOSE 5000

# Comando para executar a aplicação
CMD ["python", "app.py"]
```

### 2.2 Exemplo de requirements.txt
```
Flask==2.3.3
psycopg2-binary==2.9.7
python-dotenv==1.0.0
```

### 2.3 Construir e enviar imagem para Docker Hub

```bash
# Construir a imagem
docker build -t seu-usuario/nome-da-app:latest .

# Enviar para Docker Hub
docker push seu-usuario/nome-da-app:latest
```

## 3. Deploy no EKS

### 3.1 Configurar kubectl para o cluster EKS

Após criar o cluster EKS, configure o kubectl:

```bash
# Atualizar kubeconfig
aws eks update-kubeconfig --region us-east-2 --name app-cluster

# Verificar conexão
kubectl get nodes
```

### 3.2 Exemplo de Deployment Kubernetes

Crie um arquivo `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  labels:
    app: flask-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: seu-usuario/nome-da-app:latest
        ports:
        - containerPort: 5000
        env:
        - name: DATABASE_URL
          value: "postgresql://admin:password@rds-endpoint:5432/appdb"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  selector:
    app: flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

### 3.3 Aplicar o deployment

```bash
kubectl apply -f deployment.yaml
```

## 4. Verificações

### 4.1 Verificar status do cluster
```bash
kubectl get nodes
kubectl get pods
kubectl get services
```

### 4.2 Verificar logs da aplicação
```bash
kubectl logs -l app=flask-app
```

### 4.3 Acessar a aplicação
```bash
kubectl get service flask-app-service
```

## 5. Comandos Úteis

### 5.1 Escalar deployment
```bash
kubectl scale deployment flask-app --replicas=5
```

### 5.2 Atualizar imagem
```bash
kubectl set image deployment/flask-app flask-app=seu-usuario/nome-da-app:v2
```

### 5.3 Verificar recursos
```bash
kubectl top nodes
kubectl top pods
```

## 6. Configuração de Secrets para Docker Hub

Se necessário, criar secret para autenticação no Docker Hub:

```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=seu-usuario \
  --docker-password=sua-senha \
  --docker-email=seu-email@exemplo.com
```

E referenciar no deployment:

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: dockerhub-secret
      containers:
      # ... resto da configuração
``` 