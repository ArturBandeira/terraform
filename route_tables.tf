# Route Table Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "rt-public"
    Tier  = "public"
    Owner = var.owner_tag
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route Table Privada (única)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "rt-private"
    Tier  = "private"
    Owner = var.owner_tag
  }
}

# Rota default única apontando para NAT de us-east-2a
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat["us-east-2a"].id
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
