variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "keep_last_images" {
  description = "How many images to keep (older ones are deleted to save storage cost)"
  type        = number
  default     = 5
}
