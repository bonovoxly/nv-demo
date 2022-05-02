resource "aws_secretsmanager_secret" "client-api-key" {
  name = "${var.env}-client-api-key"
}

resource "aws_secretsmanager_secret_version" "client-api-key" {
  secret_id     = aws_secretsmanager_secret.client-api-key.id
  secret_string = var.client_api_key
}

