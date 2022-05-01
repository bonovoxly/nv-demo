#!/usr/bin/python

import base64
import boto3
import os
import json
# note - install aws-psycopg2
import psycopg2

default_limit = 500
RDS_HOST = os.getenv('RDS_HOST')
DB = os.getenv('DB').replace('-','')
FQDN = os.getenv('FQDN')
BUCKET = os.getenv("BUCKET")
expiration=os.getenv("expiration", default=20)

# sql commands
# sql select
""" list sql """
select = (
'''
    select * from files WHERE filename=%s;
''')

# sql list
""" list sql """
list = (
'''
    SELECT * FROM files LIMIT %s;
''')

def get_presigned_url(action, bucket, key):
    print(f"get_presigned_url {action} {bucket} {key}")
    conn = boto3.client('s3')
    if key.startswith("/"):
        key = key[1:]
    try:
        conn.head_object(Bucket=bucket, Key=key)
        response = conn.generate_presigned_url(action, Params={'Bucket': bucket, 'Key': key}, ExpiresIn=expiration) 
    except:
        response = ""
    return response

def getCredentials():
    credential = {}
    secret_name = "postgres"
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
    credential['host'] = RDS_HOST
    credential['db'] = DB
    return credential

def response_return(status, body):
    status = status
    myreturn = {}
    myreturn['statusCode'] = status
    myreturn['headers'] = {'Content-Type': 'application/json'}
    myreturn['body'] = body
    return myreturn

def sql_list(sql_command, tuple):
    conn = None
    results = "NA"
    print("list_files")
    try:
        credential = getCredentials()
        conn = psycopg2.connect(
            user=credential['username'],
            password=credential['password'],
            host=credential['host'],
            dbname=credential['db']
        )
        cur = conn.cursor()
        cur.execute(sql_command, tuple)
        conn.commit()
        results = cur.fetchall()
        conn.close()
    except (Exception) as error:
        print("Error...")
        print(error)
    finally:
        if conn is not None:
            conn.close()
    print(results)
    return results

# parses postgres results
def parse_tuple(tuple):
    print(tuple)
    return {
        'filename': tuple[0],
        'prefix_path': tuple[1],
        's3_bucket': tuple[2],
        'url': f"https://{FQDN}/{tuple[0]}",
        'date_added': tuple[3]
    }

# gets list of files
def list_files():
    results = sql_list(list, (default_limit,))
    parsed_list = []
    for each in results:
        parsed_list.append(parse_tuple(tuple(each)))
    myresults = response_return(200, parsed_list)
    print(myresults)
    return myresults

def download_file(path):
    results = sql_list(select, (path,))
    if len(results) == 0:
        return response_return(404, "No results found")
    elif len(results) > 1:
        return response_return(500, "Multiple results found")
    else:
        my_data = parse_tuple(tuple(results[0]))
        print(my_data)
        s3 = boto3.client('s3')
        my_file = s3.get_object(Bucket=my_data['s3_bucket'], Key=my_data['prefix_path'])
        data = my_file['Body'].read().decode('utf-8')
        myresults = data
    print(myresults)
    return myresults

def download_presigned(path):
    results = sql_list(select, (path,))
    if len(results) == 0:
        return response_return(404, "No results found")
    elif len(results) > 1:
        return response_return(500, "Multiple results found")
    else:
        my_data = parse_tuple(tuple(results[0]))
        print(my_data)
        my_file = get_presigned_url('get_object', my_data['s3_bucket'], my_data['prefix_path'])
        myresults = response_return(200, {'url': my_file})
    print(myresults)
    return myresults


def upload_file(path, content):
    if len(path.split('/'))!= 3:
        return response_return(400, "Bad Request - filename might have a slash.")
    else:
        filename = path.split('/')[2]
    s3 = boto3.client('s3')
    decode_content = base64.b64decode(content)
    s3_upload = s3.put_object(Bucket=BUCKET, Key=filename, Body=decode_content)
    return response_return(200, "File uploaded")

# for large files, we return a presigned url
def presigned_upload(path):
    if len(path.split('/'))!= 3:
        return response_return(400, "Bad Request - filename might have a slash.")
    else:
        my_file = get_presigned_url('put_object', BUCKET, path)
        myresults = response_return(200, {'url': my_file})
        print(myresults)
        return myresults

# lambda_handler (converts the event to the path)
def lambda_handler(event, context):
    print(event)
    path = event['requestContext']['http']['path'][1:]
    method = event['requestContext']['http']['method']
    print(path)
    # the default path will just call list
    if path.startswith('api/'):

        if path == 'api/list':
            print("list")
            myreturn = list_files()
        elif path.startswith('api/upload/') and method == 'PUT':
            print("upload")
            myreturn = upload_file(path, event['body'])
        elif path.startswith('api/upload_presigned/') and method == 'PUT':
            print("presigned")
            myreturn = presigned_upload(path)
        elif path.startswith('api/download_presigned/') and method == 'GET':
            print("presigned")
            myreturn = download_presigned(path)
        else:
            print("404")
            myreturn = response_return(404, "Not Found")
    elif path == '':
        print('root')
        myreturn = list_files()
    else:
        print('default')
        myreturn = download_file(path)
    try:
        mybody = json.dumps(myreturn['body'])
        return {
            'statusCode': myreturn['statusCode'],
            'headers': myreturn['headers'],
            'body': mybody
        }
    except:
        return myreturn
