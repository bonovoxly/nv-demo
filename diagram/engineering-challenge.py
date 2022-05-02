# diagram.py
from diagrams import Cluster,Diagram
from diagrams.aws.network import Route53HostedZone
from diagrams.aws.network import Route53
from diagrams.aws.network import APIGateway
from diagrams.aws.compute import LambdaFunction
from diagrams.aws.security import SecretsManager
from diagrams.aws.database import RDSPostgresqlInstance
from diagrams.aws.storage import SimpleStorageServiceS3BucketWithObjects
from diagrams.aws.database import ElastiCache

domain = "nv.lfc.sh"
env = "nv-demo"

with Diagram("Engineering Challenge", show=True):

    with Cluster("route53"):
        # route53
        route53 = Route53(f"{env}.{domain}")
        # route53_all = [route53_zone, route53]

    with Cluster("frontend"):
        # frontend
        api_gateway = APIGateway(f"{env}-api-gateway")
        api_lambda = LambdaFunction(f"{env}-api-lambda")
        authorizer_lambda = LambdaFunction(f"{env}-lambda-authorizer")
        # frontend = [api_gateway, api_lambda, authorizer_lambda]

    with Cluster("secrets"):
        # secrets
        api_secret = SecretsManager("client")
        postgres_secret = SecretsManager("postgres")
        secrets = [api_secret, postgres_secret]

    with Cluster("client-secrets"):
        # client-api-key
        client_api_key_secret = SecretsManager(f"{env}-client-api-key")
        secrets = [client_api_key_secret]

    with Cluster("backend"):
        with Cluster("postgres"):
            # postgres
            postgres = RDSPostgresqlInstance(f"{env}-postgres")
            postgres_init = LambdaFunction(f"{env}-postgres-init")
            postgres_db = [postgres, postgres_init]
        with Cluster("s3"):
            # s3-storage
            s3_bucket = SimpleStorageServiceS3BucketWithObjects(f"{env}-storage")
            postgres_update = LambdaFunction(f"{env}-postgres-update")
            s3_storage = [s3_bucket, postgres_update]
        with Cluster("elasticache"):
            # elasticache
            elasticache = ElastiCache(f"{env}-elasticache")
            elasticache_redis = [elasticache]

    # route53
    route53 >> api_gateway
    # frontend
    api_gateway >> api_lambda
    api_lambda >> authorizer_lambda
    api_lambda >> client_api_key_secret
    api_lambda >> postgres_secret
    api_lambda >> s3_bucket
    api_lambda >> postgres
    api_lambda >> elasticache
    authorizer_lambda >> api_secret
    # backend
    s3_bucket >> postgres_update
    postgres_update >> postgres_secret
    postgres_update >> postgres
    postgres_init >> postgres_secret
    postgres_init >> postgres

