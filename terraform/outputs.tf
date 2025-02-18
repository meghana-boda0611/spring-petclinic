output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.eks.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
  sensitive   = true
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.node_group.arn
}

output "vpc_id" {
  description = "VPC ID where EKS is deployed"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs where EKS nodes are running"
  value       = module.vpc.private_subnets
}

