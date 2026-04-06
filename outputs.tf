output "vpn_endpoint_arn" {
  description = "The ARN of the Client VPN Endpoint Connection."
  value       = aws_ec2_client_vpn_endpoint.default.arn
}

output "vpn_endpoint_dns_name" {
  description = "The DNS Name of the Client VPN Endpoint Connection."
  value       = aws_ec2_client_vpn_endpoint.default.dns_name
}

output "vpn_endpoint_id" {
  description = "The ID of the Client VPN Endpoint Connection."
  value       = aws_ec2_client_vpn_endpoint.default.id
}

output "private_ip" {
  description = "Internal bastion host EC2 instance private IP address."
  value       = aws_instance.jumphost.private_ip
}
