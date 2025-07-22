resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]
  description = "DB subnet group for Multi-AZ"

  tags = {
    Owner = var.owner_tag
    # CENTRODECUSTO removido intencionalmente
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "rds-mysql-app"
  allocated_storage      = var.db_allocated_storage
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  multi_az               = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

  tags = {
    Owner = var.owner_tag
    # CENTRODECUSTO removido intencionalmente
  }

  timeouts {
    create = "40m"
  }
}
