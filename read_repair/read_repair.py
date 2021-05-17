#!/usr/bin/env python2

from cassandra import ReadFailure, ReadTimeout, Timeout, Unavailable, ConsistencyLevel
from cassandra.auth import PlainTextAuthProvider 
from cassandra.cluster import Cluster 
from cassandra.query import SimpleStatement 
import sys 
import time 
from ssl import CERT_NONE, PROTOCOL_TLSv1_2 
from threading import Event
from datetime import datetime

if len(sys.argv) < 5:
    print "Insufficient parameters"
    print "Usage: python2 read_repair.py user password host keyspace table /path/to/cert.crt"
    sys.exit(1)

source_cert=""
    
source_user = sys.argv[1]
source_pass = sys.argv[2]
source_host = sys.argv[3]
source_keyspace = sys.argv[4]
source_table = sys.argv[5]
if len(sys.argv) > 6:
    source_cert = sys.argv[6]


class PagedResultHandler(object):
    def __init__(self, future):
        self.error = None
        self.finished_event = Event()
        self.future = future
        self.future.add_callbacks(
            callback=self.handle_page, errback=self.handle_error
        )

    def handle_page(self, rows):

        if self.future.has_more_pages:
            self.future.start_fetching_next_page()
        else:
            self.finished_event.set()

    def handle_error(self, exc):
        self.error = exc
        self.finished_event.set()

def execute_statement(statement):
    future = source_session.execute_async(statement)
    handler = PagedResultHandler(future)
    handler.finished_event.wait()
    if handler.error:
        raise handler.error

if source_cert != "":
    source_ssl_opts = {
        'ca_certs': source_cert,
        'ssl_version': PROTOCOL_TLSv1_2,
        'cert_reqs': CERT_NONE
    }

    source_auth_provider = PlainTextAuthProvider(
        username=source_user, password=source_pass
    )
    source_cluster = Cluster(
        [source_host], auth_provider=source_auth_provider, ssl_options=source_ssl_opts
    )
    source_session = source_cluster.connect()
else:
    source_auth_provider = PlainTextAuthProvider(
        username=source_user, password=source_pass
    )
    source_cluster = Cluster([source_host], auth_provider=source_auth_provider)
    source_session = source_cluster.connect()

print datetime.now(), "Retrieving tables..."

query = "SELECT * FROM \"" + source_keyspace + "\".\"" + source_table + "\""
statement = SimpleStatement(query, fetch_size=5000,consistency_level=ConsistencyLevel.ALL)
execute_statement(statement)
