resource "aws_elasticache_cluster" "_" {
  cluster_id           = "${var.env}-elasticache"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group._.name
  security_group_ids = [aws_security_group._.id]
}

resource "aws_security_group" "_" {
  name_prefix = "${var.env}-elasticache"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "_" {
  name       = "${var.env}-elasticache-subnet-group"
  subnet_ids = [data.aws_subnet.a-db.id, data.aws_subnet.b-db.id, data.aws_subnet.c-db.id]
}