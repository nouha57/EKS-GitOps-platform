# Route53 Module - Variables

variable "cluster_name" {
  description = "Name of the EKS cluster (used for tagging)"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Route53 hosted zone"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
