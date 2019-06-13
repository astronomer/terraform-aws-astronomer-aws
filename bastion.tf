data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com/s"
}

resource "tls_private_key" "ssh_key" {
  count = var.enable_bastion ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_ssh_key" {
  count = var.enable_bastion ? 1 : 0
  key_name   = "${var.deployment_id}_bastion_ssh_key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}

resource "local_file" "bastion_ssh_key_private" {
  count = var.enable_bastion ? 1 : 0
  filename          = pathexpand(format("~/.ssh/%s_bastion_ssh_key", var.deployment_id))
  sensitive_content = tls_private_key.ssh_key[0].private_key_pem

  # make correct permissions on file
  # make correct permissions on file
  provisioner "local-exec" {
    command = "chmod 400 ${local_file.bastion_ssh_key_private[0].filename}"
  }
}

resource "aws_security_group" "bastion_sg" {
  count = var.enable_bastion ? 1 : 0
  name        = "astronomer_bastion_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    cidr_blocks = ["${trimspace(data.http.local_ip.body)}/32"]
  }

  egress {
    # TLS (change to whatever ports you need)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group_rule" "bastion_connection_to_private_kube_api" {
  count = var.enable_bastion ? 1 : 0

  description       = "Connect the bastion to the EKS private endpoint"
  security_group_id = module.eks.cluster_security_group_id

  cidr_blocks = ["${aws_instance.bastion[0].private_ip}/32"]
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  type        = "ingress"
}

resource "aws_instance" "bastion" {

  count = var.enable_bastion ? 1 : 0

  ami = data.aws_ami.ubuntu.id

  key_name = aws_key_pair.bastion_ssh_key[0].key_name

  instance_type = var.bastion_instance_type

  subnet_id = local.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.bastion_sg[0].id]

  tags = local.tags
}

