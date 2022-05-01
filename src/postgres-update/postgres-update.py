#!/usr/bin/python

import boto3
import os
import json
# note - install aws-psycopg2
import psycopg2

RDS_HOST = os.getenv('RDS_HOST')
DB = os.getenv('DB').replace('-','')

""" inserts sql """
insert = (
'''
    INSERT INTO files (filename, prefix_path, s3_bucket, date_added)
    VALUES (%s, %s, %s, %s)
    ON CONFLICT (filename) DO UPDATE SET
    (prefix_path, s3_bucket, date_added) = (EXCLUDED.prefix_path, EXCLUDED.s3_bucket, EXCLUDED.date_added);
''')
delete = (
'''
    DELETE FROM files WHERE filename = %s;
''')

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

def get_items(event):
    filename = event['Records'][0]['s3']['object']['key'].split('/')[-1]
    prefix_path = event['Records'][0]['s3']['object']['key']
    s3_bucket = event['Records'][0]['s3']['bucket']['name']
    date_added = event['Records'][0]['eventTime']
    return filename, prefix_path, s3_bucket, date_added

def run_sql(**kwargs):
    type = kwargs['type']
    commands=kwargs['commands']
    filename=kwargs['filename']
    prefix_path=kwargs['prefix_path']
    s3_bucket=kwargs['s3_bucket']
    date_added=kwargs['date_added']
    conn = None
    results = "NA"
    try:
        credential = getCredentials()
        print(credential)
        conn = psycopg2.connect(
            user=credential['username'],
            password=credential['password'],
            host=credential['host'],
            dbname=credential['db']

        )
        cur = conn.cursor()
        if type == 'insert':
            print(f"Inserting {filename}, {prefix_path}, {s3_bucket}, {date_added}")
            cur.execute(commands, (filename, prefix_path, s3_bucket, date_added))
        elif type == 'delete':
            print(f"Deleting {filename}")
            cur.execute(commands, (filename,))
        conn.commit()
        if cur.pgresult_ptr is not None:
            results = cur.fetchone()
        conn.close()
    except (Exception) as error:
        print("Error: unable add entry...")
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return results 

def lambda_handler(event, context):
    print('event...')
    print(event)
    if event['Records'][0]['eventName'].startswith('ObjectCreated:'):
        mycommand = insert 
        mytype = 'insert'
    elif event['Records'][0]['eventName'].startswith('ObjectRemoved:'):
        mycommand = delete
        mytype = 'delete'
    filename, prefix_path, s3_bucket, date_added = get_items(event)
    run_sql(type=mytype, commands=mycommand, filename=filename, prefix_path=prefix_path, s3_bucket=s3_bucket, date_added=date_added)

