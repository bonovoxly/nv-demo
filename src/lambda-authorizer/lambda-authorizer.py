
from __future__ import print_function

import re
import base64
import boto3
import json


def get_credentials():
    credential = {}
    secret_name = "client"
    region_name = "us-east-1"
    client = boto3.client(
      service_name='secretsmanager',
      region_name=region_name
    )
    get_secret_value_response = client.get_secret_value(
      SecretId=secret_name
    )
    secret = json.loads(get_secret_value_response['SecretString'])
    credential['username'] = secret['username']
    credential['password'] = secret['password']
    return credential

def lambda_handler(event, context):
    # print(event)
    # print(f"authorization header: {event['headers']['authorization']}")
    if event['headers']['authorization'].startswith('Bearer'):
        token = event['headers']['authorization'].split(' ')[1]
        print("no support for bearer tokens")
        response = { "isAuthorized": False, "context": {} }
    elif event['headers']['authorization'].startswith('Basic'):
        auth = event['headers']['authorization'].split(' ')[1]
        user = base64.b64decode(auth).decode('utf-8').split(':')[0]
        password = base64.b64decode(auth).decode('utf-8').split(':')[1]
    credential = get_credentials()
    if user == credential['username'] and password == credential['password']:
        response = { "isAuthorized": True, "context": {} }
    else:
        response = { "isAuthorized": False, "context": {} }
    return response
