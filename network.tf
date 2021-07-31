resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = "${local.base_name}-vpc"
    },
    local.tags
  )

}

resource "aws_subnet" "pub-sub" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.availability_zone
  cidr_block              = local.subent_cidr
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "${local.base_name}-pub-sub"
    },
    local.tags
  )

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${local.base_name}-igw"
    },
    local.tags
  )
}

resource "aws_route_table" "pub-table" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${local.base_name}-pub-table"
    },
    local.tags
  )
}

resource "aws_route" "route-ipv4" {
  route_table_id         = aws_route_table.pub-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-table.id
}
