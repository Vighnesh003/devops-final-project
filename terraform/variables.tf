variable "region" {
  description = "AWS Region"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}