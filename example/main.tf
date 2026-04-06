########################################################################################################################
provider "aws" {
  region = "eu-central-1"
}
########################################################################################################################
terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.24.0"
    }
  }
}
########################################################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "myvpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_nat_gateway" "regional" {
  vpc_id            = module.vpc.vpc_id
  availability_mode = "regional"
}

resource "aws_route" "nat" {
  for_each = toset(module.vpc.private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional.id
}

module "ec2_client_vpn" {
  source = "../"

  ami                    = "ami-05852c5f195d545ea"
  public_key             = file("ec2vpn.pub")
  client_cidr            = "172.20.0.0/22"
  saml_provider_arn      = "arn:aws:iam::123456789012:saml-provider/Entra_ID_VPN"
  server_certificate_arn = "arn:aws:acm:eu-central-1:123456789012:certificate/a93b7583f-8a9f-9844-4681-b9971036bdc1"

  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "ec2vpn.mycopmany.internal"
  }
  authorization_rules = [
    {
      name                 = "my-entra-id-vpn-users"
      access_group_id      = "07fc77bc-fa54-4b61-931e-2be27857671b"
      authorize_all_groups = null
      description          = "Allow access to my vpn users Entra ID group"
      target_network_cidr  = module.vpc.vpc_cidr_block
    }
  ]
  associated_subnets = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2],
  ]
}
