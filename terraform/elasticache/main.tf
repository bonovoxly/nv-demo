resource "aws_elasticache_cluster" "_" {
  cluster_id           = "${var.env}-elasticache"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
}
