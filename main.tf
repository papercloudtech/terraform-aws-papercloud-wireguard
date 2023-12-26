resource "aws_vpc" "wireguard_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "wg-vpc-tf"
  }
}

resource "aws_subnet" "wireguard_subnet" {
  vpc_id            = aws_vpc.wireguard_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "wg-subnet-tf"
  }
}

resource "aws_internet_gateway" "wireguard_igw" {
  vpc_id = aws_vpc.wireguard_vpc.id

  tags = {
    Name = "wireguard-igw-tf"
  }
}

resource "aws_route" "wireguard_route" {
  depends_on = [aws_internet_gateway.wireguard_igw]

  route_table_id         = aws_vpc.wireguard_vpc.default_route_table_id
  gateway_id             = aws_internet_gateway.wireguard_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "wireguard_sgp" {
  name   = "wireguard-tf"
  vpc_id = aws_vpc.wireguard_vpc.id

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wireguard-sgp-tf"
  }
}

resource "aws_instance" "wireguard_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wireguard_sgp.id]
  subnet_id                   = aws_subnet.wireguard_subnet.id
  user_data                   = file("${path.module}/user-data.sh")

  tags = {
    Name = "wireguard-instance"
  }
}
