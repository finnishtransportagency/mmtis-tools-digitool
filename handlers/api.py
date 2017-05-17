#coding: utf-8
from base import BaseHandler
import pprint
import time
import datetime
import json
import tornado.web
import unicodecsv
import cStringIO


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime.datetime) or isinstance(obj, datetime.date):
        serial = obj.isoformat()
        return serial
    raise TypeError ("Type not serializable")

class ExportAllHandler(BaseHandler):
    #@tornado.web.authenticated    
    def get(self,export_format):
        raise NotImplementedError

class ExportItemHandler(BaseHandler):
    #@tornado.web.authenticated    
    def get(self,item_id,export_format):
        raise NotImplementedError