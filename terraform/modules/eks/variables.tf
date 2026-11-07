variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Check supported versions: aws eks describe-cluster-versions"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the worker nodes"
  type        = list(string)
}

variable "node_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2 # number of worker nodes to start with. The autoscaler will scale up/down as needed.
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}
