output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_group_id" {
  description = "Node Group ID"
  value       = aws_eks_node_group.main.id
}
