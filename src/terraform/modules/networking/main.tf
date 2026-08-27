# Phase 2 — Segmented VPC per research/sandbox account
# Ref: 02-Cloud-Infrastructure.md "VPC Topology (per research account)"
#
#   Public:      NAT Gateway, ALB (lab-only endpoints)
#   Private:     EC2, RDS, Lambda (research workloads)
#   Inspection:  reserved for Network Firewall, all egress routed through here
#   Management:  Systems Manager / VPC endpoints, no direct SSH ingress anywhere

locals {
  az_count    = length(var.azs)
  subnet_bits = 4 # /16 -> /20, room for 16 subnets total (4 tiers x up to 4 AZs)

  public_cidrs     = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_bits, i)]
  private_cidrs    = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_bits, i + 4)]
  inspection_cidrs = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_bits, i + 8)]
  mgmt_cidrs       = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_bits, i + 12)]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = var.name })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.name}-public-${var.azs[count.index]}", Tier = "public" })
}

resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags              = merge(var.tags, { Name = "${var.name}-private-${var.azs[count.index]}", Tier = "private" })
}

resource "aws_subnet" "inspection" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.inspection_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags              = merge(var.tags, { Name = "${var.name}-inspection-${var.azs[count.index]}", Tier = "inspection" })
}

resource "aws_subnet" "management" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.mgmt_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags              = merge(var.tags, { Name = "${var.name}-mgmt-${var.azs[count.index]}", Tier = "management" })
}

resource "aws_eip" "nat" {
  count  = local.az_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-nat-${var.azs[count.index]}" })
}

resource "aws_nat_gateway" "this" {
  count         = local.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.name}-nat-${var.azs[count.index]}" })
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# All private-subnet egress routes through the inspection tier's NAT Gateway,
# so traffic can be logged/inspected before leaving the VPC.
resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = merge(var.tags, { Name = "${var.name}-private-rt-${var.azs[count.index]}" })
}

resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "management" {
  count          = local.az_count
  subnet_id      = aws_subnet.management[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# --- Security groups: no direct SSH ingress anywhere (Systems Manager only) ---

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Lab-only ALB ingress (HTTP/HTTPS only, no SSH)"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to synthetic lab app"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

resource "aws_security_group" "workload" {
  name        = "${var.name}-workload"
  description = "Research workloads: no direct SSH ingress, SSM access only"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "From ALB only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-workload-sg" })
}

# --- VPC endpoints (avoid routing lab traffic over the public internet) ---

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private[*].id, [aws_route_table.public.id])
  tags              = merge(var.tags, { Name = "${var.name}-vpce-s3" })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.management[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.workload.id]
  tags                = merge(var.tags, { Name = "${var.name}-vpce-secretsmanager" })
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.management[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.workload.id]
  tags                = merge(var.tags, { Name = "${var.name}-vpce-ssm" })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.management[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.workload.id]
  tags                = merge(var.tags, { Name = "${var.name}-vpce-ssmmessages" })
}

data "aws_region" "current" {}

# --- VPC Flow Logs -> CloudWatch (network audit trail, 04-Security-Policy.md) ---

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/meta-quantum-harvest/vpc-flow-logs/${var.name}"
  retention_in_days = var.flow_log_retention_days
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.name}-flow-logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "flow-logs-to-cloudwatch"
  role  = aws_iam_role.flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  vpc_id               = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  tags                 = var.tags
}
