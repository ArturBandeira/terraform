#!/bin/bash

echo "=== Diagnóstico de Conectividade RDS ==="

# Configurações
DB_HOST="rds-mysql-app.cn5tkswztpz4.us-east-2.rds.amazonaws.com"
DB_PORT="3306"
DB_USER="admin"
DB_PASSWORD="cidade01"

echo "📊 Configurações:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   User: $DB_USER"
echo ""

# 1. Verificar se o RDS está rodando
echo "🔍 1. Verificando status do RDS..."
aws rds describe-db-instances --db-instance-identifier rds-mysql-app --query 'DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port]' --output table

# 2. Testar conectividade de rede
echo ""
echo "🌐 2. Testando conectividade de rede..."
if nc -z -w5 $DB_HOST $DB_PORT; then
    echo "✅ Porta $DB_PORT está acessível em $DB_HOST"
else
    echo "❌ Porta $DB_PORT não está acessível em $DB_HOST"
fi

# 3. Testar DNS
echo ""
echo "🔍 3. Testando resolução DNS..."
nslookup $DB_HOST

# 4. Testar conexão MySQL
echo ""
echo "🗄️ 4. Testando conexão MySQL..."
if command -v mysql &> /dev/null; then
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SELECT 1;" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Conexão MySQL estabelecida!"
    else
        echo "❌ Erro na conexão MySQL"
    fi
else
    echo "⚠️ MySQL client não instalado"
fi

# 5. Verificar security groups
echo ""
echo "🔒 5. Verificando security groups..."
echo "   Verifique se o security group do RDS permite tráfego da porta 3306"
echo "   das instâncias EC2 (security group: app-sg)"

# 6. Verificar route tables
echo ""
echo "🛣️ 6. Verificando route tables..."
echo "   Verifique se as subnets privadas têm rota para o NAT Gateway"

echo ""
echo "🎯 Próximos passos se houver problemas:"
echo "   1. Verificar se o RDS está 'Available'"
echo "   2. Verificar security groups"
echo "   3. Verificar NAT Gateway"
echo "   4. Verificar route tables" 