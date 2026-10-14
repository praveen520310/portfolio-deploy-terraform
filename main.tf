# ============================================================
# 1. CREATE VPC
# ============================================================

resource "aws_vpc" "portfolio" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "portfolio-deploy-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# ============================================================
# 2. CREATE PUBLIC SUBNET
# ============================================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.portfolio.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "portfolio-deploy-public-subnet"
  }
}


# ============================================================
# 3. CREATE INTERNET GATEWAY (IGW)
# ============================================================

resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id

  tags = {
    Name = "portfolio-deploy-igw"
  }
}


# ============================================================
# 4. CREATE PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.portfolio.id

  tags = {
    Name = "portfolio-deploy-public-rt"
  }
}


# ============================================================
# 5. CREATE INTERNET ROUTE
# ============================================================

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.portfolio.id
}


# ============================================================
# 6. ASSOCIATE ROUTE TABLE WITH PUBLIC SUBNET
# ============================================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# 7. CREATE SECURITY GROUP
# ============================================================

resource "aws_security_group" "portfolio" {
  name        = "portfolio-deploy-sg"
  description = "Allow HTTP website access and restricted SSH access"
  vpc_id      = aws_vpc.portfolio.id

  # Inbound: HTTP website access
  ingress {
    description = "HTTP website access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound: SSH access
  # IMPORTANT: Replace the example CIDR with your current public IP/32.
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow updates and GitHub access






  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "portfolio-deploy-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# ============================================================
# 8. GET LATEST UBUNTU 22.04 AMI
# ============================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# ============================================================
# 9. CREATE EC2 INSTANCE
# ============================================================

resource "aws_instance" "portfolio" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.portfolio.id]
  associate_public_ip_address = true

  # AWS EC2 key pair name
  key_name = "Praveen"

  # Automatically deploy the portfolio during first boot
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name        = "portfolio-deploy-ec2"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_route_table_association.public,
    aws_route.internet
  ]
}