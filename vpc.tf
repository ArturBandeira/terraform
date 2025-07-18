resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/21"
  enable_dns_hostnames = true

  tags = {
    Name  = "vpc-main"
    Owner = var.owner_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "igw"
    Owner = var.owner_tag
  }
}
