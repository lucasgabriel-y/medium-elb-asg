provider "aws" {
  region = var.region
}

#Cria o recurso para usar uma chave de acesso  
resource "aws_key_pair" "key-pair" {
  key_name   = "tf-app-rds"
  public_key = file("/id_rsa.pub")

}

#Cria a instancia EC2
resource "aws_instance" "terraform" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key-pair.key_name #Associa a chave de acesso a instancia

  tags = {
    Name = "${var.nome_instancia}"
  }

#Promove o acesso SSH a instancia
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.user_ssh
      private_key = file("/id_rsa")
    }

#Promove a instalação de recursos na instancia
    inline = [
    "sudo apt update",
    "sudo apt install apache2 -y",
    "sudo apt install mysql-client -y",
    "sudo systemctl start apache2",
    "sudo systemctl enable apache2",
    "git clone https://github.com/lucasgabriel-y/redirect.git",
    "sleep 5",
    "cd redirect",
    "sudo cp * -r /var/www/html",
    "sudo systemctl restart apache2"
    ]
  }

}

resource "aws_ebs_snapshot" "ec2_snapshot" {
  volume_id = aws_instance.terraform.root_block_device[0].volume_id
}

#Cria uma AMI com base na EC2 criada anteriormente
resource "aws_ami" "ami_app" {
  name                = var.nome-ami
  description         = var.descricao-ami
  root_device_name    = var.root-device-ami
  virtualization_type = var.tipo-virtualizacao

  ebs_block_device {
    device_name = var.root-device-ami
    snapshot_id = aws_ebs_snapshot.ec2_snapshot.id
    volume_size = 10
    delete_on_termination = true
  }

  tags = {
    Name = var.nome-ami
  }
}

#Associa um IP elastico a uma instancia
resource "aws_eip" "eip" {
  instance = aws_instance.terraform.id
}

#Exibe o IP publico associado
output "IP" {
  value = aws_eip.eip.public_ip

}