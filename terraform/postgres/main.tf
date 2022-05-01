module "postgres" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${var.env}-db"

  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group = true
  subnet_ids             = [data.aws_subnet.a-db.id, data.aws_subnet.b-db.id, data.aws_subnet.c-db.id]


  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.1"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage = 20
  # have to set this for a micro DB
  storage_encrypted = false
  

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = local.db_name
  username = local.db_creds.username
  password = local.db_creds.password
  create_random_password = false
  port     = 5432

  # db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.env}-db-sg"
  description = "nv-demo postgres security group"
  vpc_id      = data.aws_vpc.vpc.id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}
