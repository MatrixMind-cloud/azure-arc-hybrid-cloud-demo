resource "aws_vpc" "basevpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, {
    Name = "${local.vpc_name_prefix}${var.vpc_name}-vpc",
  })
}

resource "aws_subnet" "public" {
  vpc_id               = aws_vpc.basevpc.id
  cidr_block           = local.subnet_slices[0]
  availability_zone_id = "euw1-az1"
  tags = merge(local.tags, {
    Name    = "${local.sn_name_prefix}public-sn",
    mm-tier = "public",
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_subnet" "private" {
  vpc_id               = aws_vpc.basevpc.id
  cidr_block           = local.subnet_slices[1]
  availability_zone_id = "euw1-az1"
  tags = merge(local.tags, {
    Name    = "${local.sn_name_prefix}private-sn",
    mm-tier = "private",
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_default_route_table" "master" {
  default_route_table_id = aws_vpc.basevpc.default_route_table_id
  tags = merge(local.tags, {
    Name = "${local.rtb_name_prefix}master-rt",
  })
}

## primary route table setup

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.basevpc.id
  tags = merge(local.tags, {
    Name = "${local.rtb_name_prefix}public-rt",
    zone = "public",
  })
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.basevpc.id
  tags = merge(local.tags, {
    Name = "${local.rtb_name_prefix}private-rt",
    zone = "private",
  })
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.id
}


resource "aws_internet_gateway" "master" {
  vpc_id = aws_vpc.basevpc.id
  tags = merge(local.tags, {
    Name = "${local.inetgw_name_prefix}master-inetgw",
  })
}

## route table adjustments for all public subnets
resource "aws_route" "igw_public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.master.id
}

resource "aws_eip" "natgw" {
  vpc = true
  tags = merge(local.tags, {
    Name = "${local.eip_name_prefix}natgw-eip",
  })
  depends_on = [
    aws_internet_gateway.master
  ]
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public.id
  tags = merge(local.tags, {
    Name = "${local.natgw_name_prefix}natgw",
  })
}

resource "aws_route" "natgw_egress_private_single" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}
