# use this command to create the layer
# resource "null_resource" "config" {
#   provisioner "local-exec" {
#     command = "pip3 install --target ../../src/psycopg2-layer/ aws-psycopg2"
#   }
# }

module "psycopg2_local" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "${var.env}-psycopg2"
  description         = "Lambda support for psycopg2"
  compatible_runtimes = ["python3.6"]

  source_path = "../../src/psycopg2-layer/psycopg2"
}
