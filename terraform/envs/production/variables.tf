variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_account_id" {
  description = "AWS account ID where the resources will be provisioned"
  type        = string
}

variable "aws_profile" {
  description = ""
  type        = string
  default     = null
}

variable "project" {
  type    = string
  default = "devops-challenge"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "node_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "alert_email" {
  type = string
}