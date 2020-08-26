data "aws_ami" "amazonlinux" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-.*$"
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.bastion.id, aws_security_group.bastion_access.id]
  subnet_id                   = aws_subnet.public.id
  private_ip                  = cidrhost(aws_subnet.public.cidr_block, var.bastion_ip_hostnum)
  associate_public_ip_address = true
  tags                        = merge(local.tags, map("Name", "${local.naming_prefix}bastion-vm"))
  volume_tags                 = merge(local.tags, map("Name", "${local.naming_prefix}bastion-disk"))
  key_name                    = aws_key_pair.bastion_access.key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [
      # user_data,
    ]
    # prevent_destroy = true
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = local.vpc_id
  name   = "${local.naming_prefix}bastion-sg"
  tags   = merge(local.tags, map("Name", "${local.naming_prefix}bastion-sg"))

  ingress {
    description = "Allow Self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  egress {
    description = "Allow Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_access" {
  vpc_id = local.vpc_id
  name   = "${local.naming_prefix}bastion-access-sg"
  tags   = merge(local.tags, map("Name", "${local.naming_prefix}bastion_access-sg"))
}

resource "aws_security_group_rule" "bastion_access_cidrs" {
  security_group_id = aws_security_group.bastion_access.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = toset(var.bastion_access_cidrs)
}
