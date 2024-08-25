output "private_key" {
  description = "The private SSH key to connect to the EC2 instance"
  value       = tls_private_key.jenkins_key.private_key_pem
  sensitive   = true
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:8080"
}

output "instance_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.jenkins_instance.public_ip
}
