#!/usr/bin/python
from opensearchpy import OpenSearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth
import boto3
import json

host = 'opensearch-dev.aepps.com' # For example, my-test-domain.us-east-1.es.amazonaws.com
region = 'eu-central-1' # e.g. us-west-1

service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
print(awsauth)

search = OpenSearch(
    hosts = [{'host': host, 'port': 443}],
    http_auth = awsauth,
    use_ssl = True,
    verify_certs = True,
    connection_class = RequestsHttpConnection
)

document = {
    "title": "Moneyball",
    "director": "Bennett Miller",
    "year": "2011"
}

search.index(index="movies", doc_type="_doc", id="5", body=document)

print(search.get(index="movies", doc_type="_doc", id="5"))
print(json.dumps(search.info(), indent=2))
