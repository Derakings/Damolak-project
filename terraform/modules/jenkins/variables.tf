variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Public subnet to place the Jenkins server in"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster Jenkins is allowed to deploy to"
  type        = string
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group, so Jenkins can reach the Kubernetes API"
  type        = string
}

variable "allowed_cidr" {
  description = "Your IP in CIDR form (e.g. 203.0.113.10/32). Only this address can open the Jenkins UI."
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.small"
}