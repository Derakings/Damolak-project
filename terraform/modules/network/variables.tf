variable "name" {
  description = "Prefix used to name all network resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used for subnet tags so Kubernetes can find the subnets)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across"
  type        = number
  default     = 2
}
