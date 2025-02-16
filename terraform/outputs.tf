output "cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region=${var.region} --name=${var.cluster_name}"
}

