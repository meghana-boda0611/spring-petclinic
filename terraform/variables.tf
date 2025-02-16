variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default     = "eks-cluster"
}

variable "node_group_name" {
  description = "EKS Node Group Name"
  default     = "eks-node-group"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  default     = "t3.medium"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  default     = 3
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
  default     = 4
}

