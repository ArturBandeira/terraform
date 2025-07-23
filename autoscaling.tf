data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "lt-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type

  network_interfaces {
    security_groups            = [aws_security_group.app.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cd /home/ec2-user
    yum update -y
    yum install -y git python3-pip curl mysql
  
    # Clonar repositório
    git clone https://github.com/ArturBandeira/RESTful-API.git
    cd RESTful-API/RESTful/clientes_API
    
    # Instalar dependências Python
    sudo pip3 install Flask flask-cors flask-httpauth werkzeug pymysql Flask-MySQL 
    
    # Configurar banco de dados RDS
    echo "Configurando banco de dados..."
    
    # Aguardar RDS estar disponível
    sleep 60
    
    mysql -h ${aws_db_instance.rds.address} -P ${aws_db_instance.rds.port} -u ${var.db_username} -p${var.db_password} < /home/ec2-user/RESTful-API/database_desafio1.sql

     echo "Atualizando config.py para RDS..."
     cat > config.py << 'CONFIG_EOF'
from app import app
from flaskext.mysql import MySQL

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = '${var.db_username}'
app.config['MYSQL_DATABASE_PASSWORD'] = '${var.db_password}'
app.config['MYSQL_DATABASE_DB'] = 'db_clientes'
app.config['MYSQL_DATABASE_HOST'] = '${aws_db_instance.rds.address}'
app.config['MYSQL_DATABASE_PORT'] = ${aws_db_instance.rds.port}

mysql.init_app(app)
CONFIG_EOF
    
    sudo nohup python3 main.py --host=0.0.0.0 --port=80 > /var/log/clientes_api.log 2>&1 &
     
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name          = "app-server"
      Owner         = var.owner_tag
      AMBIENTE      = var.ambiente
      RESPONSAVEL   = var.responsavel
      SCHEDULE      = var.schedule
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "asg-app"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [for s in aws_subnet.app : s.id]
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Owner"
    value               = var.owner_tag
    propagate_at_launch = true
  }

  tag {
    key                 = "AMBIENTE"
    value               = var.ambiente
    propagate_at_launch = true
  }

  tag {
    key                 = "RESPONSAVEL"
    value               = var.responsavel
    propagate_at_launch = true
  }

  tag {
    key                 = "SCHEDULE"
    value               = var.schedule
    propagate_at_launch = true
  }
}
