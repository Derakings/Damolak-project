output "jenkins_url" {
  value = "http://${aws_instance.this.public_ip}:8080"
}

output "instance_id" {
  value = aws_instance.this.id
}

output "role_arn" {
  value = aws_iam_role.this.arn
}