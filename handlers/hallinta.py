#coding: utf-8
from base import BaseHandler
import pprint
import time
import datetime
import json
import tornado.web
import unicodecsv
import cStringIO
from psycopg2.extras import Json

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime.datetime) or isinstance(obj, datetime.date):
        serial = obj.isoformat()
        return serial
    raise TypeError ("Type not serializable")


class EditIndexHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self):
        curs = self.cursor

        if not self.isAdmin():
            curs.execute('SELECT i.*,u.name as modified_by_name FROM kutsuliikenne_items i LEFT JOIN jlusers u ON i.modified_by = u.user_id WHERE deleted IS NULL')
        else:
            curs.execute('SELECT i.*,u.name as modified_by_name FROM kutsuliikenne_items i LEFT JOIN jlusers u ON i.modified_by = u.user_id')
        kohteet = curs.fetchall()

        self.render2('hallinta_index',items=kohteet)

class EditMapHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'edit'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
            return None

        item_geom = { "type": "FeatureCollection","features": []}
        curs = self.cursor
        curs.execute('SELECT ST_AsGeoJSON((ST_Dump(ST_Transform(the_geom,4326))).geom) as geometry,%s as type,\'{}\'::json as properties FROM kutsuliikenne_items WHERE item_id = %s',('Feature',item_id,))
        items = curs.fetchall()

        item_geom = { "type": "FeatureCollection","features": [dict(f,geometry=json.loads(f['geometry'])) for f in items]}
        self.render2('hallinta_kartta',item_geom=json.dumps(item_geom))

    @tornado.web.authenticated 
    def post(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'edit'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
            return None

        geom = None
        try:
            geom = json.loads(self.get_argument('geom'))
        except:
            self.write("Virheellinen geometria, ei voitu tallentaa")
            return None



        curs = self.cursor

        curs.execute('''WITH geomdata AS (SELECT %s::json as fc)
            UPDATE kutsuliikenne_items SET the_geom = (SELECT ST_Transform(ST_SetSRID(ST_Multi(ST_Union(ST_GeomFromGeoJSON(feat->>'geometry'))),4326),3067) as geom FROM (SELECT json_array_elements(fc->'features') as feat FROM geomdata) as f) WHERE item_id = %s''',(json.dumps(geom),item_id))

        self.dbconn.commit()
        self.clearItemCache(item_id)
        self.redirect(self.reverse_url('muokkaa-kartta',item_id))

class EditInfoHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self,item_id=None):
        if item_id != None:
            if not self.isUserAllowedTo('item',item_id,'edit'):
                self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
                return None
        itemdata = {
            'info':{
                'lang':{
                    'fi':{},
                    'en':{},
                    'sv':{}
                },
                'weekdays':[]
            }
        }
        if item_id != None:
            if not self.isUserAllowedTo('item',item_id,'edit'):
                self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
                return None

            curs = self.cursor
            curs.execute('SELECT * FROM kutsuliikenne_items WHERE item_id = %s',(item_id,))

            itemdata = curs.fetchone()

        self.render2('hallinta_info',item=itemdata)

    @tornado.web.authenticated   
    def post(self,item_id = None):
        if item_id != None:
            if not self.isUserAllowedTo('item',item_id,'edit'):
                self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
                return None

        weekdays = ('mon','tue','wed','thu','fri','sat','sun')
        langidents = ('fi','en','sv')
        item_dict = {'lang':{},'weekdays':[False,]*7,'valid':[]}
        for li in langidents:
            item_dict['lang'][li] = {}

        for k in self.request.arguments:
            if k.startswith('valid_'):
                
                continue
            elif k.startswith('_'):
                continue
            elif k.startswith('wkd'):
                item_dict['weekdays'][weekdays.index(k[3:])] = True
            elif k[:2] in langidents:

                item_dict['lang'][k[:2]][k[2:]] = self.request.arguments[k][0]
            else:
                if len(self.request.arguments[k][0]) == 0:
                    continue
                item_dict[k] = self.request.arguments[k][0]

        item_dict['accessible'] = item_dict['accessible'] == 'y'
        if 'valid_startd' in self.request.arguments:
            for i in xrange(len(self.request.arguments['valid_startd'])):
                item_dict['valid'].append({
                    'start_date':self.request.arguments['valid_startd'][i],
                    'end_date':self.request.arguments['valid_endd'][i],
                    'start_time':self.request.arguments['valid_startt'][i],
                    'end_time':self.request.arguments['valid_endt'][i],
                    })

        self.write(pprint.pformat(item_dict))

        current_user = self.current_user
        curs = self.cursor
        if item_id == None:
            curs.execute('INSERT INTO kutsuliikenne_items (created,created_by,public,info) VALUES (current_timestamp,%s,false,%s) RETURNING item_id;',(current_user['user_id'],Json(item_dict)))
            new_item_id = curs.fetchone()
            item_id = new_item_id['item_id']
            curs.execute("INSERT INTO jlauthorizations (authorized_type,authorized_id,target_service,target_resource,target_ident,permission,valid_from,valid_to) VALUES (%s,%s,%s,%s,%s,%s,current_timestamp,%s)",('user',current_user['user_id'],'kutsuliikenne','item',item_id,'admin',None))
        else:
            curs.execute('UPDATE kutsuliikenne_items SET last_modified=current_timestamp,modified_by=%s,info=%s WHERE item_id = %s',(current_user['user_id'],Json(item_dict),item_id))
        self.dbconn.commit()

        self.clearItemCache(item_id)

        self.redirect(self.reverse_url('muokkaa-info',item_id))

class EditAuthHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'admin'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseisen liikenteen valtuuksia')
            return None    
        authorizations = self.application.security.getAuthorizationsForItem('kutsuliikenne','item',item_id)
        

        curs = self.cursor

        curs.execute('SELECT user_id as id,name FROM jlusers WHERE valid_from < current_timestamp AND (valid_to IS NULL OR (valid_to IS NOT NULL AND valid_to > current_timestamp))')

        users = curs.fetchall()


        curs.execute('SELECT group_id as id,name FROM jlgroups WHERE valid_from < current_timestamp AND (valid_to IS NULL OR (valid_to IS NOT NULL AND valid_to > current_timestamp))')

        groups = curs.fetchall()


        self.render2('hallinta_auth',authorizations=authorizations,users=users,groups=groups,item_id=item_id)


    @tornado.web.authenticated    
    def post(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'admin'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseisen liikenteen valtuuksia')
            return None       
        authorizations = []
        if 'atype' in self.request.arguments:
            for i in xrange(len(self.request.arguments['atype'])):
                a = {
                    'authorized_type':self.request.arguments['atype'][i],
                    'authorized_id':self.request.arguments['aid'][i],
                    'permission':self.request.arguments['arole'][i],
                    'valid_from':self.request.arguments['avalidfrom'][i],
                    'valid_to':self.request.arguments['avalidto'][i],
                    }
                
                for dk in ('valid_from','valid_to'):
                    try:
                        a[dk] = datetime.datetime.strptime(a[dk],'%d.%m.%Y')
                    except ValueError:
                        a[dk] = None
                authorizations.append(a)
        

        self.write(pprint.pformat(authorizations))

        ''''
            authorization_id serial,
            authorized_type text,
            authorized_id int,
            target_service text,
            target_resource text,
            target_ident text,
            permission text,
            valid_from timestamp with time zone,
            valid_to timestamp with time zone,
        '''
        
        curs = self.cursor

        args_str = ','.join(curs.mogrify("(%s,%s,%s,%s,%s,%s,%s,%s)", (a['authorized_type'],a['authorized_id'],'kutsuliikenne','item',item_id,a['permission'],a['valid_from'],a['valid_to'])) for a in authorizations)
        curs.execute('DELETE FROM jlauthorizations WHERE target_service = %s AND target_resource = %s AND target_ident = %s',('kutsuliikenne','item',item_id))
        if len(authorizations) > 0:
            curs.execute("INSERT INTO jlauthorizations (authorized_type,authorized_id,target_service,target_resource,target_ident,permission,valid_from,valid_to) VALUES " + args_str)
        

        self.dbconn.commit()
        self.redirect(self.reverse_url('muokkaa-valtuudet',item_id))

class EditStatusHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'edit'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
            return None       
        curs = self.cursor

        curs.execute('''UPDATE kutsuliikenne_items SET public = NOT public WHERE item_id = %s''',(int(item_id),))

        self.dbconn.commit()
        self.clearItemCache(item_id)
        self.redirect(self.reverse_url('muokkaa'))

class EditDeleteHandler(BaseHandler):
    #@tornado.web.authenticated    
    def get(self,item_id):
        if not self.isUserAllowedTo('item',item_id,'admin'):
            self.write(u'Sinulla ei ole oikeutta muokata kyseistä liikennettä')
            return None       
        curs = self.cursor

        if not self.isAdmin():
            curs.execute('''UPDATE kutsuliikenne_items SET deleted = current_timestamp WHERE item_id = %s''',(int(item_id),))
        else:
            curs.execute('''UPDATE kutsuliikenne_items SET deleted = CASE WHEN deleted IS NULL THEN current_timestamp ELSE NULL END WHERE item_id = %s''',(int(item_id),))
        self.dbconn.commit()
        self.clearItemCache(item_id)
        self.redirect(self.reverse_url('muokkaa'))

class LoginHandler(BaseHandler):
    def get(self):
        token = self.get_argument('avain',None)
        user = self.get_argument('kayttaja',None)
        if token != None and user != None:
            self.__doLogin(user,token)
            kuntanumero = self.get_argument('kunta',None)
            vuosi = self.get_argument('vuosi',None)
            if kuntanumero != None and vuosi != None:
                try:
                    kuntanumero = int(kuntanumero)
                    vuosi = int(vuosi)
                    self.redirect(self.reverse_url('muokkaa',kuntanumero,vuosi))
                    return None
                except ValueError:
                    self.redirect(self.reverse_url('index'))
                    return None
            else:
                self.redirect(self.reverse_url('index'))
                return None                
        else:
            self.render2('hallinta_login')

    def post(self):
        token = self.get_argument('token')
        user = self.get_argument('user')
        loginsucc = self.__doLogin(user,token)

        if loginsucc:
            self.redirect(self.reverse_url('index'))


    def __doLogin(self,user,token):
        
        token = token.strip()
        user = user.strip()


        curs = self.cursor
        curs.execute('SELECT * FROM jlusers WHERE username = %s AND valid_from IS NOT NULL AND valid_from < current_timestamp AND (valid_to IS NULL OR valid_to > current_timestamp)',(user,))
        userkey = curs.fetchone()
        curs.close()

        if userkey == None:
            self.write('Tuntematon tai vanhentunut tunnus.')
            return False
        verify = self.application.security.verify(token, userkey['passkey'])
        if not verify:
            self.write('Virheellinen avain')
            return False

        self.set_secure_cookie("user_id", str(userkey['user_id']))

        return True
        

class LogoutHandler(BaseHandler):
    @tornado.web.authenticated    
    def get(self):
        self.clear_cookie('user_id')
        self.redirect(self.reverse_url('index'))