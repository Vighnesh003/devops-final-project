output "cluster_name" {
  value = aws_eks_cluster.devops_eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.devops_eks.endpoint
}

output "cluster_security_group" {
  value = aws_security_group.devops_sg.id
}

output "vpc_id" {
  value = aws_vpc.devops_vpc.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}