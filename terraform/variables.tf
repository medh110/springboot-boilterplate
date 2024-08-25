variable "aws_region" {
  description = "The AWS region"
  default     = "ap-southeast-2"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "jenkins-key"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-01fb4de0e9f8f22a7"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
