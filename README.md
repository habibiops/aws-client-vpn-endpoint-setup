# terraform-aws-client-vpn

This is the code repo for the following [blog post]( https://habibiops.com/p/aws-client-vpn-endpoint-setup/).

# terraform-docs

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 6.24.0 |

## Providers

| Name                                              | Version   |
|---------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.24.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type     |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                             | resource |
| [aws_ec2_client_vpn_authorization_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule)   | resource |
| [aws_ec2_client_vpn_endpoint.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint)                       | resource |
| [aws_ec2_client_vpn_network_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route)                             | resource |
| [aws_instance.jumphost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                                    | resource |
| [aws_key_pair.jumphost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)                                                    | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                         | resource |
| [aws_security_group.jumphost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                        | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                               | resource |
| [aws_security_group_rule.jumphost-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                       | resource |
| [aws_security_group_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                   | resource |

## Inputs

| Name                                                                                                     | Description                                                                                                                                                                               | Type                                                                                                                                                                                                                           | Default      | Required |
|----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|:--------:|
| <a name="input_additional_routes"></a> [additional\_routes](#input\_additional\_routes)                  | A list of additional routes that should be attached to the Client VPN endpoint.                                                                                                           | <pre>list(object({<br/>    destination_cidr_block = string<br/>    description            = string<br/>    target_vpc_subnet_id   = string<br/>    name                   = optional(string)<br/>  }))</pre>                   | `[]`         |    no    |
| <a name="input_ami"></a> [ami](#input\_ami)                                                              | AMI id for the internal bastion host EC2 instance.                                                                                                                                        | `string`                                                                                                                                                                                                                       | n/a          |   yes    |
| <a name="input_associated_subnets"></a> [associated\_subnets](#input\_associated\_subnets)               | List of subnets to associate with the VPN endpoint.                                                                                                                                       | `list(string)`                                                                                                                                                                                                                 | n/a          |   yes    |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules)            | List of objects describing the authorization rules for the client VPN.                                                                                                                    | <pre>list(object({<br/>    name                 = string<br/>    access_group_id      = string<br/>    authorize_all_groups = bool<br/>    description          = string<br/>    target_network_cidr  = string<br/>  }))</pre> | `[]`         |    no    |
| <a name="input_client_cidr"></a> [client\_cidr](#input\_client\_cidr)                                    | Network CIDR to use for clients.                                                                                                                                                          | `string`                                                                                                                                                                                                                       | n/a          |   yes    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                              | Instance type for the internal bastion host EC2 instance.                                                                                                                                 | `string`                                                                                                                                                                                                                       | `"t2.micro"` |    no    |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key)                                       | SSH public key to access the internal bastion host EC2 instance.                                                                                                                          | `string`                                                                                                                                                                                                                       | n/a          |   yes    |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn)                | SAML provider ARN.                                                                                                                                                                        | `string`                                                                                                                                                                                                                       | n/a          |   yes    |
| <a name="input_server_certificate_arn"></a> [server\_certificate\_arn](#input\_server\_certificate\_arn) | The ACM cert ARN of the server certificate to be used for the Client VPN.                                                                                                                 | `string`                                                                                                                                                                                                                       | n/a          |   yes    |
| <a name="input_session_timeout_hours"></a> [session\_timeout\_hours](#input\_session\_timeout\_hours)    | The maximum session duration is a trigger by which end-users are required to re-authenticate prior to establishing a VPN session. Default value is 24. Valid values: 8 \| 10 \| 12 \| 24. | `string`                                                                                                                                                                                                                       | `"24"`       |    no    |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel)                                 | Indicates whether split-tunnel is enabled on VPN endpoint.                                                                                                                                | `bool`                                                                                                                                                                                                                         | `true`       |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                           | A map of tags to assign to the resources.                                                                                                                                                 | `map(string)`                                                                                                                                                                                                                  | `{}`         |    no    |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol)               | Transport protocol used by the TLS sessions.                                                                                                                                              | `string`                                                                                                                                                                                                                       | `"udp"`      |    no    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                   | ID of VPC to attach VPN to.                                                                                                                                                               | `string`                                                                                                                                                                                                                       | n/a          |   yes    |

## Outputs

| Name                                                                                                      | Description                                            |
|-----------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip)                                      | Internal bastion host EC2 instance private IP address. |
| <a name="output_vpn_endpoint_arn"></a> [vpn\_endpoint\_arn](#output\_vpn\_endpoint\_arn)                  | The ARN of the Client VPN Endpoint Connection.         |
| <a name="output_vpn_endpoint_dns_name"></a> [vpn\_endpoint\_dns\_name](#output\_vpn\_endpoint\_dns\_name) | The DNS Name of the Client VPN Endpoint Connection.    |
| <a name="output_vpn_endpoint_id"></a> [vpn\_endpoint\_id](#output\_vpn\_endpoint\_id)                     | The ID of the Client VPN Endpoint Connection.          |
