locals {
  name = "ec2vpn"
}

########################################################################################################################
# Ec2 Client VPN Endpoint
########################################################################################################################
resource "aws_cloudwatch_log_group" "default" {
  name = local.name
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = local.name
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr
  self_service_portal    = "disabled"
  transport_protocol     = var.transport_protocol

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = var.saml_provider_arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.default.name
  }

  split_tunnel          = var.split_tunnel
  session_timeout_hours = var.session_timeout_hours
  security_group_ids    = [aws_security_group.default.id]
  vpc_id                = var.vpc_id

  tags = var.tags
}

resource "aws_security_group" "default" {
  name        = local.name
  description = "Allow EC2 client VPN traffic"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.default.id
  to_port                  = 0
  type                     = "ingress"
  source_security_group_id = aws_security_group.default.id
  description              = "Allow all ingress from designated sources"
}

resource "aws_security_group_rule" "egress" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.default.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
}

resource "aws_ec2_client_vpn_network_association" "default" {
  for_each = {
    for k, v in var.associated_subnets : tostring(k) => v
  }

  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "default" {
  for_each = {
    for k, v in var.authorization_rules : coalesce(lookup(v, "name", null), tostring(k)) => v
  }

  access_group_id        = lookup(each.value, "access_group_id", null)
  authorize_all_groups   = lookup(each.value, "authorize_all_groups", null)
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  description            = each.value.description
  target_network_cidr    = each.value.target_network_cidr
}

resource "aws_ec2_client_vpn_route" "default" {
  for_each = {
    for k, v in var.additional_routes : coalesce(v.name, tostring(k)) => v
  }

  description            = lookup(each.value, "description", null)
  destination_cidr_block = each.value.destination_cidr_block
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  target_vpc_subnet_id   = each.value.target_vpc_subnet_id

  depends_on = [
    aws_ec2_client_vpn_network_association.default
  ]

  timeouts {
    create = "5m"
    delete = "5m"
  }
}
########################################################################################################################
# Internal jumphost
########################################################################################################################
resource "aws_key_pair" "jumphost" {
  key_name   = "jumphost"
  public_key = var.public_key
}

resource "aws_security_group" "jumphost" {
  name        = "jumphost"
  description = "Jumphost EC2 client VPN"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ssh" {
  from_port                = 22
  protocol                 = "TCP"
  security_group_id        = aws_security_group.jumphost.id
  to_port                  = 22
  type                     = "ingress"
  source_security_group_id = aws_security_group.default.id
  description              = "Allow all ssh connections from VPN clients"
}

resource "aws_security_group_rule" "jumphost-egress" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jumphost.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
}

resource "aws_instance" "jumphost" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.jumphost.key_name
  subnet_id              = var.associated_subnets[0]
  vpc_security_group_ids = [aws_security_group.jumphost.id]

  tags = {
    Name = "internal-jumphost"
  }
}
