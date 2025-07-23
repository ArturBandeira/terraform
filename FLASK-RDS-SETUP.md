# Configuração Flask + RDS MySQL

## Visão Geral

Este documento explica como configurar a aplicação Flask para conectar ao RDS MySQL, considerando o arquivo `config.py` original.

## Configuração Original vs RDS

### 🔧 Configuração Original (config.py)
```python
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'cidade01'
app.config['MYSQL_DATABASE_DB'] = 'db_clientes'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)
```

### 🚀 Configuração RDS (config.py atualizado)
```python
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'admin'
app.config['MYSQL_DATABASE_PASSWORD'] = 'cidade01'
app.config['MYSQL_DATABASE_DB'] = 'db_clientes'
app.config['MYSQL_DATABASE_HOST'] = 'rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com'
mysql.init_app(app)
```

## Métodos de Configuração

### 1. Configuração Automática (Recomendado)

O user data das instâncias EC2 já está configurado para:
- ✅ Clonar o repositório
- ✅ Instalar dependências Python
- ✅ Configurar banco de dados RDS
- ✅ Atualizar `config.py` automaticamente
- ✅ Iniciar aplicação Flask

**Para aplicar:**
```bash
terraform apply
```

### 2. Configuração Manual

#### Opção A: Script Completo
```bash
# Conectar em uma instância EC2
ssh -i your-key.pem ec2-user@[INSTANCE-IP]

# Navegar para o diretório da aplicação
cd RESTful-API/RESTful/clientes_API

# Executar script completo
chmod +x setup-complete.sh
./setup-complete.sh
```

#### Opção B: Script Apenas Config
```bash
# Conectar em uma instância EC2
ssh -i your-key.pem ec2-user@[INSTANCE-IP]

# Navegar para o diretório da aplicação
cd RESTful-API/RESTful/clientes_API

# Executar script de configuração
chmod +x setup-flask-config.sh
./setup-flask-config.sh
```

#### Opção C: Comandos Manuais
```bash
# Conectar em uma instância EC2
ssh -i your-key.pem ec2-user@[INSTANCE-IP]

# Navegar para o diretório da aplicação
cd RESTful-API/RESTful/clientes_API

# Fazer backup do config.py original
cp config.py config.py.backup

# Criar novo config.py
cat > config.py << 'EOF'
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'admin'
app.config['MYSQL_DATABASE_PASSWORD'] = 'cidade01'
app.config['MYSQL_DATABASE_DB'] = 'db_clientes'
app.config['MYSQL_DATABASE_HOST'] = 'rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com'
mysql.init_app(app)
EOF

# Configurar banco de dados
mysql -h rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com -u admin -pcidade01 < /home/ec2-user/RESTful-API/database.sql
```

## Configurações do RDS

- **Endpoint**: `rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com:3306`
- **Usuário**: `admin` (não `root`)
- **Senha**: `cidade01`
- **Database**: `db_clientes`
- **Engine**: MySQL 8.0

## Verificação

### 1. Testar Conexão MySQL
```bash
mysql -h rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com -u admin -pcidade01 -e "USE db_clientes; SHOW TABLES;"
```

### 2. Testar Conexão Python
```bash
python3 -c "
import pymysql
try:
    connection = pymysql.connect(
        host='rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com',
        user='admin',
        password='cidade01',
        database='db_clientes'
    )
    print('✅ Conexão estabelecida!')
    connection.close()
except Exception as e:
    print(f'❌ Erro: {e}')
"
```

### 3. Verificar Aplicação Flask
```bash
# Verificar se está rodando
ps aux | grep python3

# Ver logs
sudo tail -f /var/log/clientes_api.log

# Testar endpoint
curl http://localhost:80/
```

## Troubleshooting

### Erro: "Access denied for user 'root'"
- **Causa**: Usuário `root` não existe no RDS
- **Solução**: Usar usuário `admin`

### Erro: "Can't connect to MySQL server"
- **Causa**: RDS não está acessível
- **Solução**: Verificar security groups (porta 3306)

### Erro: "Unknown database 'db_clientes'"
- **Causa**: Banco não foi criado
- **Solução**: Executar `database.sql`

### Erro: "Connection timeout"
- **Causa**: Problemas de rede
- **Solução**: Verificar NAT Gateway e route tables

## Logs Úteis

```bash
# Logs da aplicação Flask
sudo tail -f /var/log/clientes_api.log

# Logs do user-data
sudo tail -f /var/log/user-data.log

# Logs do MySQL (se aplicável)
sudo tail -f /var/log/mysqld.log
```
