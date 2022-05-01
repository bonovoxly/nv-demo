# nv-demo

This is the code for the engineering challenge.

## Requirements

- Admin access to a particular AWS account.
- Terraform v1.1.7

## Overview

The following infrastructure will be deployed:

- S3 Terraform state bucket.
- VPC.
- Route53 zone.
- AWS API Gateway.
- Front end lambda.
- API lambda.
- Upload authorizor lambda.
- DB table/schema lambda.
- S3 bucket for uploaded storage.
- AWS RDS Postgres DB.
- AWS ElastiCache.
- AWS Secrets.

Note, while in some cases the Terraform projects would not be needed (it sounds like the DB and other settings are provided), I wanted to create these and present them, so I could have a fully functioning demo.

## Deployment

These deployments are locked to a playground AWS account I use (you'll see the account ID locked in `provider.tf`). Again, I am Terraforming things that might already be provided, for completeness.

- Terraform the remote state. Depending on team size, you may want to use DynamoDB for state locking.

```bash
cd ./terraform/nv-demo-terraform-state
terraform init
terraform apply
```

- Terraform the VPC. CIDR and names are found in `variables.tf`.

```bash
cd ./terraform/vpc
terraform init
terraform apply
```

- Terraform the AWS secrets. **This is for this demo only**. I'm putting the secrets in the actual repo, not something I would normally do. For this demo, it makes it easy to provide access to review the infrastructure.

```bash
cd ./terraform/secrets
terraform init
terraform apply
```

- Terraform the postgres project. This includes a postgres-init lambda, which would be used for initializing a DB environment.

```bash
cd ./terraform/postgres
terraform init
terraform apply
```

To initialize the DB, run the `postgres-init` lambda:

```bash
# Can update the lambda to perform migrations in the future!
aws lambda invoke --function-name nv-demo-postgres-init --cli-binary-format raw-in-base64-out --payload '{"name": "init"}' response.json
```

In the AWS logs, you should see the initialization

```bash
❯ aws logs tail "/aws/lambda/nv-demo-postgres-init" --follow

2022-04-30T22:39:17.740000+00:00 2022/04/30/[$LATEST]6d35e39638b44742b714327eccd06a48 START RequestId: b640040d-b5d3-4e2c-80f7-c3ee47215af2 Version: $LATEST
2022-04-30T22:39:17.741000+00:00 2022/04/30/[$LATEST]6d35e39638b44742b714327eccd06a48 {'name': 'init'}
2022-04-30T22:39:19.350000+00:00 2022/04/30/[$LATEST]6d35e39638b44742b714327eccd06a48 END RequestId: b640040d-b5d3-4e2c-80f7-c3ee47215af2
2022-04-30T22:39:19.350000+00:00 2022/04/30/[$LATEST]6d35e39638b44742b714327eccd06a48 REPORT RequestId: b640040d-b5d3-4e2c-80f7-c3ee47215af2  Duration: 1608.89 ms    Billed Duration: 1609 ms        Memory Size: 128 MB  Max Memory Used: 77 MB   Init Duration: 411.87 ms
```

- Terraform the s3-storage. This includes a lambda that updates the list of files in the S3 bucket via an S3 bucket notification subscription:

```bash
cd ./terraform/s3-storage
terraform init
terraform apply
```


