variable "ami" {
  description = "AMI id for the internal bastion host EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the internal bastion host EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "SSH public key to access the internal bastion host EC2 instance."
  type        = string
}

variable "client_cidr" {
  description = "Network CIDR to use for clients."
  type        = string
}

variable "saml_provider_arn" {
  description = "SAML provider ARN."
  type        = string
}

variable "server_certificate_arn" {
  description = "The ACM cert ARN of the server certificate to be used for the Client VPN."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "additional_routes" {
  description = "A list of additional routes that should be attached to the Client VPN endpoint."
  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
    name                   = optional(string)
  }))
  default = []
}

variable "associated_subnets" {
  description = "List of subnets to associate with the VPN endpoint."
  type        = list(string)
}

variable "authorization_rules" {
  description = "List of objects describing the authorization rules for the client VPN."
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
  default = []
}

variable "vpc_id" {
  description = "ID of VPC to attach VPN to."
  type        = string
}

variable "split_tunnel" {
  description = "Indicates whether split-tunnel is enabled on VPN endpoint."
  type        = bool
  default     = true
}

variable "session_timeout_hours" {
  description = "The maximum session duration is a trigger by which end-users are required to re-authenticate prior to establishing a VPN session. Default value is 24. Valid values: 8 | 10 | 12 | 24."
  type        = string
  default     = "24"

  validation {
    condition     = contains(["8", "10", "12", "24"], var.session_timeout_hours)
    error_message = "The maximum session duration must one be one of: 8, 10, 12, 24."
  }
}

variable "transport_protocol" {
  description = "Transport protocol used by the TLS sessions."
  type        = string
  default     = "udp"
  validation {
    condition     = contains(["udp", "tcp"], var.transport_protocol)
    error_message = "Invalid protocol type must be one of: udp, tcp."
  }
}
