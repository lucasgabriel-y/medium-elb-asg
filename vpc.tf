
resource "aws_vpc" "apprds_vpc" {
  cidr_block = "10.0.0.0/16" # Bloco de endereços IP da VPC

  tags = {
    Name = "tf-vpc"
  }
}

# Cria uma subnet pública
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.apprds_vpc.id
  cidr_block = "10.0.1.0/24" # Bloco de endereços IP da subnet
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet_a"
  }
}

# Cria uma subnet pública
resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.apprds_vpc.id
  cidr_block = "10.0.2.0/24" # Bloco de endereços IP da subnet
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_b"
  }
}

# Cria um grupo de segurança para a subnet pública
resource "aws_security_group" "public_security_group" {
  name_prefix = "public_security_group"
  vpc_id      = aws_vpc.apprds_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "public_security_group"
  }
}

#cria um grupo de segurança para o ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Acesso a partir do ELB"
  vpc_id      = aws_vpc.apprds_vpc.id

   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb_sg"
  }
}


#cria um grupo de segurança para o ASG
resource "aws_security_group" "asg_sg" {
  name        = "asg_sg"
  description = "Grupo de Seguranca do ASG"
  vpc_id      = aws_vpc.apprds_vpc.id

    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg_sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Acesso"
  vpc_id      = aws_vpc.apprds_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name = "ec2_sg"
  }
}

# Cria uma subnet privada
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.apprds_vpc.id
  cidr_block = "10.0.3.0/24" # Bloco de endereços IP da subnet
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_a"
  }
}

# Cria uma subnet privada
resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.apprds_vpc.id
  cidr_block = "10.0.4.0/24" # Bloco de endereços IP da subnet
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_subnet_b"
  }
}

# Cria um gateway de internet para a VPC
resource "aws_internet_gateway" "gateway_internet" {
  vpc_id = aws_vpc.apprds_vpc.id

  tags = {
    Name = "gateway_internet"
  }
}

# Cria uma rota para permitir o tráfego da subnet pública para a Internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.apprds_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway_internet.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associa a subnet pública com a tabela de rotas pública
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associa a subnet pública B com a tabela de rotas pública
resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
