#coding:utf-8
import os,sys
import tornado.auth
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from tornado.web import url

import psycopg2
import psycopg2.extensions
psycopg2.extensions.register_type(psycopg2.extensions.UNICODE)
psycopg2.extensions.register_type(psycopg2.extensions.UNICODEARRAY)
from psycopg2.pool import ThreadedConnectionPool,PersistentConnectionPool

import codecs

import handlers.kutsuliikenne
import handlers.hallinta
import handlers.admin
import handlers.api
import string
import math

import redis

from tornado.options import define, options

import translations
import livibetasecurity


define("port", default=8600, help="run on the given port", type=int)
define("dbuser", help="DB user", type=str)
define("dbpasswd", help="DB password", type=str)
define("dbname", help="DB name", type=str)
define("dbhost", default='localhost', help="DB host", type=str)
define("dbport", default=5432, help="DB port", type=int)


def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d




class Application(tornado.web.Application):
    def __init__(self):
        
        routes = [
            url(r"/joukkoliikenne/kutsujoukkoliikenne/$", handlers.kutsuliikenne.IndexHandler,name='index'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/katselu/([\d]*?)$", handlers.kutsuliikenne.ViewHandler,name='view'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/kartta$", handlers.kutsuliikenne.MapHandler,name='map'),            
            url(r"/joukkoliikenne/kutsujoukkoliikenne/kirjaudu$", handlers.hallinta.LoginHandler,name='login'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/ulos$", handlers.hallinta.LogoutHandler,name='logout'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/vie/([a-z]*?)$", handlers.kutsuliikenne.ExportHandler,name='export'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/vie/([a-z]*?)/all$", handlers.kutsuliikenne.ExportHandler,name='export-all'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/vie/([a-z]*?)/all.zip$", handlers.kutsuliikenne.ExportHandler,name='export-all-zip'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/vie/([a-z]*?)/([\d]*?)$", handlers.kutsuliikenne.ExportHandler,name='export-item'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/$", handlers.hallinta.EditIndexHandler,name='muokkaa'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/uusi_kohde/$", handlers.hallinta.EditInfoHandler,name='muokkaa-uusi'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/([\d]*)/status$", handlers.hallinta.EditStatusHandler,name='muokkaa-status'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/([\d]*)/poista$", handlers.hallinta.EditDeleteHandler,name='muokkaa-poista'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/([\d]*)/kartta$", handlers.hallinta.EditMapHandler,name='muokkaa-kartta'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/([\d]*)/tiedot$", handlers.hallinta.EditInfoHandler,name='muokkaa-info'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/muokkaa/([\d]*)/valtuudet$", handlers.hallinta.EditAuthHandler,name='muokkaa-valtuudet'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta", handlers.admin.IndexHandler,name='admin'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/kayttaja", handlers.admin.UserHandler,name='admin-avain-uusi'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/kayttaja/([\d]*?)/paata_voimassaolo$", handlers.admin.DeleteUserHandler,name='admin-avain-poisto'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/kayttaja/([\d]*?)$", handlers.admin.UserHandler,name='admin-avain'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/ryhma", handlers.admin.GroupHandler,name='admin-ryhma-uusi'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/ryhma/([\d]*?)/paata_voimassaolo$", handlers.admin.DeleteGroupHandler,name='admin-ryhma-poisto'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/ryhma/([\d]*?)/poista_jasen/([\d]*?)", handlers.admin.DeleteGroupUserHandler,name='admin-ryhma-poistajasen'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/ryhma/([\d]*?)/lisaa_jasen$", handlers.admin.AddGroupUserHandler,name='admin-ryhma-lisaajasen'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/hallinta/ryhma/([\d]*?)$", handlers.admin.GroupHandler,name='admin-ryhma'),            
            url(r"/joukkoliikenne/kutsujoukkoliikenne/api/liikenne/([\w]*?)$", handlers.api.ExportAllHandler,name='api-all'),
            url(r"/joukkoliikenne/kutsujoukkoliikenne/api/liikenne/([\d]*)/([\w]*?)$", handlers.api.ExportItemHandler,name='api-item'),

        ]
        settings = dict(
            template_path=os.path.join(os.path.dirname(__file__), "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            xsrf_cookies=True,
            debug=True,
            static_url_prefix='/joukkoliikenne/kutsujoukkoliikenne/static/',
            login_url="/joukkoliikenne/kutsujoukkoliikenne/kirjaudu",
            cookie_secret="|_oveO?@Re,982Zh2|08wX$g%We8*&C0I1D_bWKd6|8Sh*Nr.2=10:A?941pZ;D"
        )
        tornado.web.Application.__init__(self, routes, **settings)

        assert options.dbhost
        assert options.dbport
        assert options.dbname
        assert options.dbuser
        assert options.dbpasswd
        self.dbconn = PersistentConnectionPool(1,50,host=options.dbhost,port=options.dbport,dbname=options.dbname,user=options.dbuser,password=options.dbpasswd)

        self.security = livibetasecurity.LiViBetaSecurity(self.dbconn)
        self.redis = redis.StrictRedis(host='localhost', port=6379, db=0,decode_responses=True)

        self.fieldtrans = translations.fieldtrans


def main():
    tornado.options.parse_command_line()
    http_server = tornado.httpserver.HTTPServer(Application())
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()


if __name__ == "__main__":
    main()
