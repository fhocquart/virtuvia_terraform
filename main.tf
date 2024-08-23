
# Terraform Configuration for AWS Environment

provider "aws" {
  region  = "us-east-1"
  profile = "default" # Update this if you use a specific AWS profile
}

# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}


# Create an Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

# Create a Route Table
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.app_vpc.id
  name   = "app_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Route Table Association (Dynamically References the Route Table Created Above)
resource "aws_route_table_association" "app_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id # Reference your dynamically created subnet
  route_table_id = aws_route_table.app_route_table.id # Reference the dynamically created route table
}

# Fetch the latest Ubuntu AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instance
resource "aws_instance" "app_server" {                 # Ensure consistent naming here
  ami                         = data.aws_ami.ubuntu.id # Use the declared data source
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = "femi_keypair" # Use the new key pair name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]

  tags = {
    Name = "App Server"
  }
}

# Outputs
output "instance_ip" {
  value = aws_instance.app_server.public_ip
}
