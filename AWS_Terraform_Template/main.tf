locals {
  isGlobalMktImage    = contains(["global_marketplace"], var.ami) ? 1 : 0
  vpc_name            = var.vpc_name
  subnet_name         = var.virtual_subnet_name
  selected_ami        = local.isGlobalMktImage == 1 ? data.aws_ami.global_marketplace_ami[0].id : var.ami
  security_group      = var.default_security_group ? aws_security_group.default_security_group[0].id : data.aws_security_group.existing[0].id
  security_group_name = var.default_security_group ? "default_security_group" : var.security_group
  templates           = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")]
  proxy_port          = regex(":(\\d+)$", var.proxy_url)[0]
  is_proxy_defined    = length(var.proxy_url) > 0
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnet" "existing_subnet" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_name]
  }
}

resource "aws_security_group" "default_security_group" {
  count  = var.default_security_group ? 1 : 0
  name   = local.security_group_name
  vpc_id = data.aws_vpc.existing_vpc.id
  # Ingress rules: Allow inbound traffic only if a proxy is defined
  dynamic "ingress" {
    for_each = local.is_proxy_defined ? [1] : []
    content {
      from_port        = tonumber(local.proxy_port)
      to_port          = tonumber(local.proxy_port)
      protocol         = "tcp"
      cidr_blocks      = [var.proxy_cidr_block]
      ipv6_cidr_blocks = [var.proxy_ipv6_cidr_blocks]
    }
  }
  # Egress rules: Allow only HTTPS (port 443)
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  tags = {
    Name = local.security_group_name
  }
}

data "aws_security_group" "existing" {
  count = var.default_security_group ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [local.security_group_name]
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
  vpc_security_group_ids      = [local.security_group]
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
  vpc_security_group_ids      = [local.security_group]
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
