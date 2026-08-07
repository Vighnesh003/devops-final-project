# -----------------------------------
# Amazon EKS Managed Node Group
# -----------------------------------

resource "aws_eks_node_group" "devops_nodes" {

  cluster_name    = aws_eks_cluster.devops_eks.name
  node_group_name = "devops-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  instance_types = ["t3.medium"]

  capacity_type = "ON_DEMAND"

  scaling_config {
  desired_size = 1
  min_size     = 1
  max_size     = 1
}

  disk_size = 20

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
    aws_eks_cluster.devops_eks
  ]

  tags = {
    Name = "devops-node-group"
  }
}