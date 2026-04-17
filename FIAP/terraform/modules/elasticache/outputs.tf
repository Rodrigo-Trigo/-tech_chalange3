output "elasticache_cluster_id" {
  description = "ElastiCache cluster ID"
  value       = aws_elasticache_cluster.redis.cluster_id
}

output "elasticache_endpoint" {
  description = "ElastiCache endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "elasticache_port" {
  description = "ElastiCache port"
  value       = aws_elasticache_cluster.redis.port
}
