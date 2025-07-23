#!/bin/bash

# Script para configurar o config.py da aplicação Flask para RDS
# Execute este script de uma instância EC2 que tenha acesso ao RDS

echo "=== Configurando config.py para RDS ==="

# Configurações do banco (obtidas do Terraform)
DB_HOST="rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com"
DB_USER="admin"
DB_PASSWORD="cidade01"
DB_NAME="db_clientes"

echo "📊 Configurações do banco:"
echo "   Host: $DB_HOST"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "config.py" ]; then
    echo "❌ Arquivo config.py não encontrado!"
    echo "   Certifique-se de estar no diretório da aplicação Flask."
    echo "   Execute: cd RESTful-API/RESTful/clientes_API"
    exit 1
fi

# Fazer backup do config.py original
cp config.py config.py.backup
echo "✅ Backup criado: config.py.backup"

# Criar novo config.py com configurações do RDS
cat > config.py << EOF
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = '$DB_USER'
app.config['MYSQL_DATABASE_PASSWORD'] = '$DB_PASSWORD'
app.config['MYSQL_DATABASE_DB'] = '$DB_NAME'
app.config['MYSQL_DATABASE_HOST'] = '$DB_HOST'
mysql.init_app(app)
EOF

echo "✅ config.py atualizado com configurações do RDS!"

# Verificar se o arquivo foi criado corretamente
echo ""
echo "📄 Conteúdo do novo config.py:"
cat config.py

echo ""
echo "🔍 Testando conexão com o banco..."
python3 -c "
import pymysql
try:
    connection = pymysql.connect(
        host='$DB_HOST',
        user='$DB_USER',
        password='$DB_PASSWORD',
        database='$DB_NAME'
    )
    print('✅ Conexão com banco estabelecida!')
    connection.close()
except Exception as e:
    print(f'❌ Erro ao conectar: {e}')
"

echo ""
echo "🎯 Próximos passos:"
echo "   1. Reiniciar a aplicação Flask"
echo "   2. Verificar logs: sudo tail -f /var/log/clientes_api.log"
echo "   3. Testar endpoints da API" 