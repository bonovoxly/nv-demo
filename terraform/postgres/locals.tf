locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.postgres.secret_string
  )
  db_name = replace(var.env, "-", "")
}

