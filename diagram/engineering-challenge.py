# diagram.py
from diagrams import Diagram
from diagrams.aws.network import Route53HostedZone
from diagrams.aws.network import APIGateway
from diagrams.aws.compute import LambdaFunction
# from diagrams.aws import AWS
# from diagrams.aws.compute import EC2
# from diagrams.aws.database import RDS
# from diagrams.aws.network import ELB

with Diagram("Engineering Challenge", show=True):
    route53 =  Route53HostedZone("nv-demo.lfc.hs")
    api_gateway = APIGateway("API Gateway")
    fe_lambda = LambdaFunction("Frontend Lambda")
    api_lambda = LambdaFunction("API Lambda")
    
    AWS.network.Route53HostedZone("nv-demo.lfc.hs") >> AWS.network.APIGateway("API Gateway") >> AWS.compute.LambdaFunction("Front End")