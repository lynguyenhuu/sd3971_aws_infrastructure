variable "project" {
  type        = string
  default     = "sd3971"
  description = "Project name, follow defined tables, i.e Datajet "
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment, e.g. 'prod', 'staging', 'dev'"
}
variable "owner" {
  type        = string
  default     = ""
  description = "Owner/ maitainner of resource, follow define owner table, i.e "
}

variable "name" {
  type        = string
  default     = "sd3971_devops"
  description = "Solution name, e.g. `app` or `jenkins`"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ec2_instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "/secrets"
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "ssh_public_key_file" {
  type        = string
  description = "Name of existing SSH public key file (e.g. `id_rsa.pub`)"
  default     = null
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm"
}

variable "private_key_extension" {
  type        = string
  default     = ".pem"
  description = "Private key extension"
}

variable "public_key_extension" {
  type        = string
  default     = ".pub"
  description = "Public key extension"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}
