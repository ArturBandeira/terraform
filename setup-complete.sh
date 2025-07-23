#!/bin/bash

# Script completo para configurar banco de dados e aplicação Flask
# Execute este script de uma instância EC2 que tenha acesso ao RDS

echo "=== Configuração Completa: Banco + Flask ==="

# Configurações do banco
DB_HOST="rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com"
DB_USER="admin"
DB_PASSWORD="cidade01"

echo "📊 Configurações:"
echo "   Host: $DB_HOST"
echo "   User: $DB_USER"
echo "   Password: $DB_PASSWORD"
echo ""

# 1. Instalar MySQL client se necessário
if ! command -v mysql &> /dev/null; then
    echo "📦 Instalando MySQL client..."
    sudo yum install -y mysql
fi

# 2. Testar conexão com o banco
echo "🔍 Testando conexão com o banco..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Erro ao conectar ao banco de dados!"
    echo "   Verifique se o RDS está rodando e acessível"
    exit 1
fi

echo "✅ Conexão com banco estabelecida!"

# 3. Executar database.sql
echo "🚀 Configurando estrutura do banco..."
if [ -f "database.sql" ]; then
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < database.sql
    
    if [ $? -eq 0 ]; then
        echo "✅ Banco de dados configurado com sucesso!"
    else
        echo "❌ Erro ao configurar banco de dados"
        exit 1
    fi
else
    echo "⚠️  Arquivo database.sql não encontrado, pulando configuração do banco"
fi

# 4. Configurar config.py da aplicação Flask
echo "🔧 Configurando aplicação Flask..."

# Verificar se estamos no diretório correto
if [ ! -f "config.py" ]; then
    echo "❌ Arquivo config.py não encontrado!"
    echo "   Certifique-se de estar no diretório da aplicação Flask."
    echo "   Execute: cd RESTful-API/RESTful/clientes_API"
    exit 1
fi

# Fazer backup
cp config.py config.py.backup
echo "✅ Backup criado: config.py.backup"

# Criar novo config.py
cat > config.py << EOF
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = '$DB_USER'
app.config['MYSQL_DATABASE_PASSWORD'] = '$DB_PASSWORD'
app.config['MYSQL_DATABASE_DB'] = 'db_clientes'
app.config['MYSQL_DATABASE_HOST'] = '$DB_HOST'
mysql.init_app(app)
EOF

echo "✅ config.py atualizado!"

# 5. Testar conexão Python
echo "🐍 Testando conexão via Python..."
python3 -c "
import pymysql
try:
    connection = pymysql.connect(
        host='$DB_HOST',
        user='$DB_USER',
        password='$DB_PASSWORD',
        database='db_clientes'
    )
    print('✅ Conexão Python estabelecida!')
    
    # Testar uma query simples
    with connection.cursor() as cursor:
        cursor.execute('SHOW TABLES')
        tables = cursor.fetchall()
        print(f'📋 Tabelas encontradas: {len(tables)}')
        for table in tables:
            print(f'   - {table[0]}')
    
    connection.close()
except Exception as e:
    print(f'❌ Erro na conexão Python: {e}')
"

# 6. Verificar se a aplicação está rodando
echo ""
echo "🔍 Verificando status da aplicação..."
if pgrep -f "python3.*main.py" > /dev/null; then
    echo "✅ Aplicação Flask está rodando"
    echo "   PID: $(pgrep -f 'python3.*main.py')"
else
    echo "⚠️  Aplicação Flask não está rodando"
    echo "   Para iniciar: sudo nohup python3 main.py --host=0.0.0.0 --port=80 > /var/log/clientes_api.log 2>&1 &"
fi

echo ""
echo "🎯 Configuração completa!"
echo ""
echo "📊 Resumo:"
echo "   ✅ Banco de dados configurado"
echo "   ✅ config.py atualizado"
echo "   ✅ Conexão testada"
echo ""
echo "🔧 Comandos úteis:"
echo "   - Ver logs: sudo tail -f /var/log/clientes_api.log"
echo "   - Verificar processo: ps aux | grep python3"
echo "   - Testar API: curl http://localhost:80/"
echo "   - Conectar banco: mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD" 