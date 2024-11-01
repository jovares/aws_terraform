terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}
# Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
# NETWORKING
# VPC
resource "aws_vpc" "vpc_lab-003" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name : "${var.proyect}"
  }
}
#SUBNET's
resource "aws_subnet" "lab-003_public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_lab-003.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.proyect}"
  }
}
resource "aws_subnet" "lab-003_public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_lab-003.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.proyect}"
  }
}
resource "aws_subnet" "lab-003_private_subnet_a" {
  vpc_id                  = aws_vpc.vpc_lab-003.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name : "${var.proyect}"
  }
}
resource "aws_subnet" "lab-003_private_subnet_b" {
  vpc_id                  = aws_vpc.vpc_lab-003.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name : "${var.proyect}"
  }
}
# IGW
resource "aws_internet_gateway" "lab-003_IGW" {
  vpc_id = aws_vpc.vpc_lab-003.id
  tags = {
    Name : "${var.proyect}"
  }
}
# ROUTE TABLE
resource "aws_route_table" "lab-003_RT" {
  vpc_id = aws_vpc.vpc_lab-003.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-003_IGW.id
  }
  tags = {
    Name : "${var.proyect}"
  }
}

resource "aws_route_table_association" "lab-003_public_subnet_a_rta" {
  subnet_id      = aws_subnet.lab-003_public_subnet_a.id
  route_table_id = aws_route_table.lab-003_RT.id
}

resource "aws_route_table_association" "lab-003_public_subnet_b_rta" {
  subnet_id      = aws_subnet.lab-003_public_subnet_b.id
  route_table_id = aws_route_table.lab-003_RT.id
}

# NAT GW for Private Network
resource "aws_eip" "lab-003_NGW" {
  depends_on = [aws_internet_gateway.lab-003_IGW]
}
resource "aws_nat_gateway" "lab-003_ANGW" {
  allocation_id = aws_eip.lab-003_NGW.id
  subnet_id     = aws_subnet.lab-003_private_subnet_a.id
}
# ROUTE TABLE for Private Network
resource "aws_route_table" "lab-003_RT_P" {
  vpc_id = aws_vpc.vpc_lab-003.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab-003_ANGW.id
  }
}
resource "aws_route_table_association" "lab-003_RT_PA" {
  subnet_id      = aws_subnet.lab-003_private_subnet_a.id
  route_table_id = aws_route_table.lab-003_RT_P.id
}
resource "aws_route_table_association" "lab-003_RT_PB" {
  subnet_id      = aws_subnet.lab-003_private_subnet_b.id
  route_table_id = aws_route_table.lab-003_RT_P.id
}
# INSTANCES
resource "aws_instance" "lab-003_instances_public" {
  ami             = "ami-0fff1b9a61dec8a5f"
  instance_type   = "t2.micro"
  user_data       = <<-EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  subnet_id       = aws_subnet.lab-003_public_subnet_a.id
  security_groups = [aws_security_group.lab-003_security_groups_public.id]
}
resource "aws_instance" "lab-003_instances_private" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  user_data     = <<-EOF
#!/bin/bash
# Add a new user
USERNAME="test"
PASSWORD="t3st..2020"

# Create the user and set the password
sudo useradd -m -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Grant sudo privileges (optional)
sudo usermod -aG wheel $USERNAME

# Configure SSH to allow password authentication
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo systemctl restart sshd

# Add a welcome message to the user's home directory
echo "Welcome, $USERNAME! Your AWS instance is ready." | sudo tee /home/$USERNAME/welcome.txt

# Ensure permissions are set for the home directory
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
EOF

  subnet_id       = aws_subnet.lab-003_private_subnet_a.id
  security_groups = [aws_security_group.lab-003_security_groups_private.id]

  tags = {
    Name = "private"
  }
}

# Security Group
resource "aws_security_group" "lab-003_security_groups_public" {
  vpc_id      = aws_vpc.vpc_lab-003.id
  name        = "lab-003_security_groups_public"
  description = "lab-003_security_groups_public"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_security_group" "lab-003_security_groups_private" {
  vpc_id      = aws_vpc.vpc_lab-003.id
  name        = "lab-003_security_groups_private"
  description = "lab-003_security_groups_private"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "allow_ssh_from_public_sg" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lab-003_security_groups_private.id
  source_security_group_id = aws_security_group.lab-003_security_groups_public.id # Reference to the other security group
}