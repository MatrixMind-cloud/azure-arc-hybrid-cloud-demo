
locals {
  naming_prefix      = "sndbox-arc-"
  vpc_name_prefix    = local.naming_prefix
  sn_name_prefix     = local.naming_prefix
  inetgw_name_prefix = local.naming_prefix
  rtb_name_prefix    = local.naming_prefix
  eip_name_prefix    = local.naming_prefix
  natgw_name_prefix  = local.naming_prefix
  tags = {
    environment = "sandbox"
  }
  subnet_slices = cidrsubnets(var.vpc_cidr_block, 3, 2)
  vpc_id        = aws_vpc.basevpc.id

  windows_cloudinit = templatefile("${path.module}/assets/cloudinit.tpl.ps1", {
    arc_appId          = var.arc_data.appId
    arc_appSec         = var.arc_data.appSec
    arc_resourceGroup  = var.arc_data.resourceGroup
    arc_tenantId       = var.arc_data.tenantId
    arc_location       = var.arc_data.location
    arc_subscriptionId = var.arc_data.subscriptionId
  })
}

resource "aws_key_pair" "bastion_access" {
  key_name   = "${local.naming_prefix}bastion-key"
  public_key = var.bastion_default_pubkey
}

resource "tls_private_key" "windows" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "windows_access" {
  key_name   = "${local.naming_prefix}windows-key"
  public_key = tls_private_key.windows.public_key_openssh
}
