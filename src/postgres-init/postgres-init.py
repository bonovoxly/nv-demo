#!/usr/bin/python

import boto3
import os
import json
# note - install aws-psycopg2
import psycopg2

# env variables
RDS_HOST = os.getenv('RDS_HOST')
DB = os.getenv('DB').replace('-','')

# get postgres credentials from the AWS secretsmanager
def get_credentials():
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

# create tables
def create_tables():
    """ create tables in the PostgreSQL database"""
    commands = (
        """ CREATE TABLE files (
                filename VARCHAR(255) NOT NULL,
                prefix_path VARCHAR(255) NOT NULL,
                s3_bucket VARCHAR(255) NOT NULL,
                date_added VARCHAR(255) NOT NULL,
                primary key (filename),
                UNIQUE (filename)
                );
        """)
    conn = None
    results = "NA"
    try:
        credential = get_credentials()
        conn = psycopg2.connect(
            user=credential['username'],
            password=credential['password'],
            host=credential['host'],
            dbname=credential['db']
        )
        cur = conn.cursor()
        cur.execute("select * from information_schema.tables where table_name=%s", ('files',))
        if cur.fetchone()[0]:
            print("table already exists. skipping...")
        else:
            cur.execute(commands)
            conn.commit()
        results = cur.fetchone()
        conn.close()
    except (Exception) as error:
        print("Error: unable to create tables")
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return results 

def lambda_handler(event, context):
    print(event)
    create_tables()

if __name__ == '__main__':
    create_tables()
