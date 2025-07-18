locals {
  azs           = ["us-east-2a", "us-east-2c"]
  public_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  app_cidrs     = ["10.0.4.0/24", "10.0.5.0/24"]
  db_cidrs      = ["10.0.6.0/24", "10.0.7.0/24"]
}

# Subnets Públicas
resource "aws_subnet" "public" {
  for_each                = zipmap(local.azs, local.public_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name  = "public-${each.key}"
    Tier  = "public"
    Owner = var.owner_tag
  }
}

# Subnets Privadas (App)
resource "aws_subnet" "app" {
  for_each          = zipmap(local.azs, local.app_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name  = "app-${each.key}"
    Tier  = "private-app"
    Owner = var.owner_tag
  }
}

# Subnets Privadas (DB)
resource "aws_subnet" "db" {
  for_each          = zipmap(local.azs, local.db_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name  = "db-${each.key}"
    Tier  = "private-db"
    Owner = var.owner_tag
  }
}
