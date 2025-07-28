# Create main VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}


# PUBLIC SUBNETS — used for both EKS control plane and worker nodes
resource "aws_subnet" "public_subnet" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.availability_zones[idx]
    }
  }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "${local.name_prefix}-public-subnet-${each.value.az}"
    project                                       = var.project_name
    environment                                   = var.environment
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}


# PRIVATE SUBNETS — not used in this dev project (no NAT), but included for future expansion (e.g., RDS)
resource "aws_subnet" "private_subnet" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.availability_zones[idx]
    }
  }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name                                          = "${local.name_prefix}-private-subnet-${each.value.az}"
    project                                       = var.project_name
    environment                                   = var.environment
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}


# Internet Gateway (required for public subnets)
resource "aws_internet_gateway" "public_subnet_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# PUBLIC Route Table with default route to Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_subnet_igw.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}


# Route table associations, depends on public subnets and route table
resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


# PRIVATE Route Table (no internet access)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.name_prefix}-private-rt"

  }
}


# Route table associations for private subnets, no routes to the internet
resource "aws_route_table_association" "private_rt_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}