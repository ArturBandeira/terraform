resource "aws_eip" "nat" {
  for_each = toset(local.azs)
  vpc      = true

  tags = {
    Name  = "eip-nat-${each.key}"
    Owner = var.owner_tag
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name  = "nat-${each.key}"
    Owner = var.owner_tag
  }
}
