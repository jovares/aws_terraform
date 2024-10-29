
# Networking
resource "aws_vpc" "nginx_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.project}.nginx",
  }
}
resource "aws_subnet" "nginx_subnet_private" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "192.168.0.0/24"
  
  tags = {
    Name = "${var.project}.nginx_private"
  }
}
resource "aws_subnet" "nginx_subnet_public" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}.nginx_public"
  }
}
# IGW
resource "aws_internet_gateway" "nginx_IGW" {
  vpc_id = aws_vpc.nginx_vpc.id
  tags = {
    Name = "${var.project}.nginx_IGW"
  }
}
# ROUTE TABLE
resource "aws_route_table" "nginx_RouteTable_public" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_IGW.id
  }
  tags = {
    Name = "${var.project}.ninx_ROUTE"
  }
}
resource "aws_route_table_association" "nginx_RouteTable_public_association" {
  subnet_id      = aws_subnet.nginx_subnet_public.id
  route_table_id = aws_route_table.nginx_RouteTable_public.id

}
# INSTANCES 
resource "aws_instance" "nginx_instance" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  user_data     = <<-EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  key_name      = aws_key_pair.nginx_key.key_name
  vpc_security_group_ids = [
    aws_security_group.nginx_sg.id
  ]
  subnet_id = aws_subnet.nginx_subnet_public.id
  associate_public_ip_address = true
  tags = {
    Name        = "${var.project}.nginx"
    Environment = "production"
  }
}
resource "aws_security_group" "nginx_sg" {
  vpc_id      = aws_vpc.nginx_vpc.id
  name        = "aws_nginx_security_group"
  description = "aws_nginx_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["201.191.46.91/32"]

  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]

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
resource "aws_key_pair" "nginx_key" {
  key_name   = "nginx_key"
  public_key = file("terraformpublic")
}
