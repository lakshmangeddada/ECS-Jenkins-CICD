#Config Variables
import os
import boto3

#client = boto3.client('lambda')

#response = client.list_tags(Resource='arn:aws:lambda:us-east-1:123456789012:function:my-function')

#print(response)
#Environment
ENV = 'dev'

#DB credentials and S3 bucket name.
if ENV == 'dev':
    secretName='dev-secretname1'
    OS_URL="vpc-0c7b3b6b.us-east-1.es.amazonaws.com"
    SQS_URL="https://sqs.us-east-1.amazonaws.com/123456789012/MyQueue"
    S3_BUCKET_NAME = 'dev-bucket'
    QUERY_BODY={
        "query": {
            "bool": {
                "must": {
                    "match_phrase": {

                    }
                },
            },
        },
    }
elif ENV == 'qa':
    secretName='qa-secretname1'
    OS_URL="vpc-0c7b3b6b.us-east-1.es.amazonaws.com"
    SQS_URL="https://sqs.us-east-1.amazonaws.com/123456789012/MyQueue"
    S3_BUCKET_NAME = 'dev-bucket'
    QUERY_BODY={
        "query": {
            "bool": {
                "must": {
                    "match_phrase": {

                    }
                },
            },
        },
    }
elif ENV == 'prod':
    secretName='prd-secretname1'
    OS_URL="vpc-0c7b3b6b.us-east-1.es.amazonaws.com"
    SQS_URL="https://sqs.us-east-1.amazonaws.com/123456789012/MyQueue"
    S3_BUCKET_NAME = 'dev-bucket'
    QUERY_BODY={
        "query": {
            "bool": {
                "must": {
                    "match_phrase": {

                    }
                },
            },
        },
    }    