import tornado.web
from jinja2 import Environment, FileSystemLoader, TemplateNotFound
import logging
import os
import psycopg2.extras
import json
import pprint
from dateutil.tz import tzlocal
import datetime
import time
import bleach

app_log = logging.getLogger("tornado.application")

class TemplateRendering:
    """
    A simple class to hold methods for rendering templates.
    """
    def render_template(self, template_name, **kwargs):
        template_dirs = []
        if self.settings.get('template_path', ''):
            template_dirs.append(
                self.settings["template_path"]
            )
        template_name = '%s.tpl' % template_name
        env = Environment(loader=FileSystemLoader(template_dirs))
        env.filters['jsond'] = json.dumps
        env.filters['linkify'] = bleach.linkify
        try:
            template = env.get_template(template_name)
        except TemplateNotFound:
            raise TemplateNotFound(template_name)
        content = template.render(kwargs)
        return content

class BaseHandler(tornado.web.RequestHandler, TemplateRendering):

    @property
    def cursor(self,*args):
        if not hasattr(self,'dbconn'):
            self.dbconn = self.application.dbconn.getconn()
        if not hasattr(self,'curs'):
            self.curs = self.dbconn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        return self.curs
    
    @property
    def redis(self):
        return self.application.redis
    
    def clearItemCache(self,item_id):
        
        if item_id:
            self.redis.delete('kutsuliikenne::active::%s' % None)
        self.redis.delete('kutsuliikenne::active::%s' % item_id)
        self.redis.delete('kutsuliikenne::active::html')

    def on_finish(self):
        if hasattr(self,'curs') and not self.curs.closed:
            self.curs.close()
            print 'Cursor closed'
            
        if hasattr(self,'dbconn'):
            self.application.dbconn.putconn(self.dbconn)
            print 'Connection put away'
        
    def get_current_user(self):
        user_id = None
        try:
            user_id = self.get_secure_cookie("user_id")
        except ValueError:
            self.clear_cookie('user_id')
            return False
        except:
            raise


        if user_id:
            curs = self.cursor
            curs.execute('SELECT * FROM jlusers WHERE user_id = %s',(user_id,))
            user = curs.fetchone()
            pprint.pprint(user)
            if not user:
                self.clear_cookie('user_id')
                return None

            user['is_admin'] = user['role'] == 'admin'
            if user['valid_to']:
                if user['valid_to'] < datetime.datetime.now(tzlocal()):
                    self.clear_cookie('user_id')
                    return None

            if user['valid_from']:
                if user['valid_from'] > datetime.datetime.now(tzlocal()):
                    self.clear_cookie('user_id')
                    return None

            authorizations = self.application.security.getUserAuthorizations(user_id)

            user['authorizations'] = authorizations

            
            return dict(user)

        self.clear_cookie('user_id')
        return None


    def isUserAllowedTo(self,resource,ident,action,service='kutsuliikenne'):
        return self.application.security.isAllowedTo(service,resource,ident,action,self.current_user)

        #return True
        #raise NotImplementedError

    def isAdmin(self):
        return self.current_user and self.current_user['role'] == 'admin'
    
    def render(self, template_name, **kwargs):
        kwargs.update({
            'settings': self.settings,
            'STATIC_URL': self.settings.get('static_url_prefix', '/static/'),
            'request': self.request,
            'xsrf_token': self.xsrf_token,
            'xsrf_form_html': self.xsrf_form_html,
            'reverse_url':self.reverse_url,
            'current_user':self.current_user,
            'userAllowedTo':self.isUserAllowedTo,
            'isAdmin':self.isAdmin(),
            'now':time.time,
            'fromtimestamp':datetime.datetime.fromtimestamp,
            'fieldtrans':self.application.fieldtrans
        })

        content = self.render_template(template_name, **kwargs)

        return content    
    def render2(self, template_name, **kwargs):
        content = self.render(template_name,**kwargs)
        self.write(content)
