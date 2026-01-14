resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.app_1a.id, aws_subnet.app_1c.id]
  description = "DB subnet group for Multi-AZ"

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "rds-mysql-app"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "cidade01"
  multi_az               = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

  tags = {
    Name = "rds-mysql-app"
  }

  timeouts {
    create = "40m"
  }
}
