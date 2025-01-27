locals {
  isGlobalMktImage = contains(["global_marketplace"], var.ami) ? 1 : 0
  vpc_id           = var.vpc_id
  subnet_id        = var.virtual_subnet_id
  selected_ami     = local.isGlobalMktImage == 1 ? data.aws_ami.global_marketplace_ami[0].id : var.ami
  templates        = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")]
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "existing_subnet" {
  filter {
    name   = "subnet-id"
    values = [local.subnet_id]
  }
}

data "aws_security_group" "existing" {
  filter {
    name   = "group-id"
    values = [var.security_group_id]
  }
}

data "aws_ami" "global_marketplace_ami" {
  count       = local.isGlobalMktImage == 1 ? 1 : 0
  most_recent = true
  owners      = ["aws-marketplace"]
  filter {
    name   = "name"
    values = ["qVSA-AWS.x86*"]
  }
}

resource "aws_instance" "vm_instance_ignore_ami_change" {
  count                       = var.ignore_ami_changes ? var.vm_count : 0
  ami                         = local.selected_ami
  instance_type               = var.scanner_instance_type
  subnet_id                   = data.aws_subnet.existing_subnet.id
  monitoring                  = true
  ipv6_address_count          = var.assign_ipv6_public_ip ? 1 : 0
  associate_public_ip_address = var.assign_public_ip ? true : false
  vpc_security_group_ids      = [data.aws_security_group.existing.id]
  lifecycle {
    ignore_changes = [ami, ]
  }
  tags = {
    Name = "${var.scanner_name}-${count.index}"
  }
  user_data = base64encode(local.templates[count.index])
}

resource "aws_instance" "vm_instance" {
  count                       = var.ignore_ami_changes ? 0 : var.vm_count
  ami                         = local.selected_ami
  instance_type               = var.scanner_instance_type
  subnet_id                   = data.aws_subnet.existing_subnet.id
  monitoring                  = true
  ipv6_address_count          = var.assign_ipv6_public_ip ? 1 : 0
  associate_public_ip_address = var.assign_public_ip ? true : false
  vpc_security_group_ids      = [data.aws_security_group.existing.id]
  tags = {
    Name = "${var.scanner_name}-${count.index}"
  }
  user_data = base64encode(local.templates[count.index])
}

resource "aws_ec2_instance_state" "instance_status" {
  count       = var.vm_count
  instance_id = var.ignore_ami_changes ? aws_instance.vm_instance_ignore_ami_change[count.index].id : aws_instance.vm_instance[count.index].id
  state       = var.instance_state
}
