resource "aws_instance" "windows" {
  ami                    = "ami-0b5271aea7b566f9a"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.windows.id, aws_security_group.windows_access.id]
  subnet_id              = aws_subnet.private.id
  private_ip             = cidrhost(aws_subnet.private.cidr_block, var.windows_ip_hostnum)
  user_data              = base64encode(local.windows_cloudinit)
  tags                   = merge(local.tags, map("Name", "${local.naming_prefix}windows-vm"))
  volume_tags            = merge(local.tags, map("Name", "${local.naming_prefix}windows-disk"))
  key_name               = aws_key_pair.windows_access.key_name
  get_password_data      = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 32
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

resource "aws_security_group" "windows" {
  vpc_id = local.vpc_id
  name   = "${local.naming_prefix}windows-sg"
  tags   = merge(local.tags, map("Name", "${local.naming_prefix}windows-sg"))

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

resource "aws_security_group" "windows_access" {
  vpc_id = local.vpc_id
  name   = "${local.naming_prefix}windows_access-sg"
  tags   = merge(local.tags, map("Name", "${local.naming_prefix}windows_access-sg"))
}

resource "aws_security_group_rule" "windows_access_cidrs" {
  security_group_id        = aws_security_group.windows_access.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.bastion.id
}
