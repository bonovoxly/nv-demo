resource "aws_secretsmanager_secret" "postgres" {
  name = "postgres"
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id     = aws_secretsmanager_secret.postgres.id
  secret_string = "{\"username\":\"nvuser\",\"password\":\"mypassword-hunter2\"}"
}

resource "aws_secretsmanager_secret" "client" {
  name = "client"
}

resource "aws_secretsmanager_secret_version" "client" {
  secret_id     = aws_secretsmanager_secret.client.id
  secret_string = "{\"username\":\"nvclient\",\"password\":\"mysecretkey\"}"
}
