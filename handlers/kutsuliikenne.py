#!/usr/bin/python
# -*- coding: utf-8 -*-

from base import BaseHandler
import pprint
import time
import datetime
import json
import tornado.web
import unicodecsv
import cStringIO
import unicodecsv as csv
import ujson
import zipfile
import itertools

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime.datetime) or isinstance(obj,
            datetime.date):
        serial = obj.isoformat()
        return serial
    raise TypeError('Type not serializable')


def getActiveItems(self, item_id=None):
    active_items = self.redis.get('kutsuliikenne::active::%s' % item_id)
    if not active_items:

        # self.cursor.execute('''SELECT item_id,(jsonb_array_elements(info->'valid')->>'end_date')::text as end_date,(jsonb_array_elements(info->'valid')->>'end_time')::text as end_time  FROM kutsuliikenne_items WHERE deleted IS NULL AND public = true''')

        self.cursor.execute('''SELECT 
        item_id,
        info,
        ST_AsGeoJSON(ST_Multi(the_geom),7) as jsongeom,
       (SELECT array_agg(ST_AsKML(a.geom)) FROM (SELECT (ST_dump(the_geom)).geom as geom) as a) as kmlgeoms,
        extract(epoch from MIN(to_timestamp(start_date||' '||start_time,'dd.mm.YYYY HH24:MI'))) as minstart,
        extract(epoch from MAX(to_timestamp(end_date||' '||end_time,'dd.mm.YYYY HH24:MI'))) as maxend
            FROM
        (SELECT item_id,info,jsonb_array_elements(i.info->'valid') as valid,ST_Transform(the_geom,4326) as the_geom  FROM kutsuliikenne_items i WHERE deleted IS NULL AND public = true%s) as a,
        jsonb_to_record(valid) as x(start_date text,start_time text,end_date text,end_time text) GROUP BY item_id,info,the_geom HAVING MAX(to_timestamp(end_date||' '||end_time,'dd.mm.YYYY HH24:MI')) > current_timestamp'''
                            % ((' AND item_id = %s' if item_id else ''
                            )), ((item_id, ) if item_id else None))
        active_items = self.cursor.fetchall()
        self.redis.setex('kutsuliikenne::active::%s' % item_id, 30
                         * 60, ujson.dumps(active_items))
    else:
        active_items = ujson.loads(active_items)

    return active_items


class IndexHandler(BaseHandler):

    def get(self):

        active_html = self.redis.get('kutsuliikenne::active::html')
        if not active_html:
            active_items = getActiveItems(self)
            active_html = self.render('kutsuliikenne_active_table',
                    items=active_items)
            self.redis.setex('kutsuliikenne::active::html', 30 * 60,
                             active_html)

        self.render2('kutsuliikenne_index',
                     active_table_html=active_html)


class ViewHandler(BaseHandler):

    def get(self, item_id):
        item = getActiveItems(self,item_id)
        if len(item) == 0:
            self.write('Unknown service')
            return
        self.render2('kutsuliikenne_view', item=item[0])


class MapHandler(BaseHandler):
    def get(self):
        self.render2('kutsuliikenne_map')


class ExportHandler(BaseHandler):

    def get(self, format='geojson', item_id=None):
        active_items = getActiveItems(self, item_id)
        force_list = item_id == None
        
        if len(active_items) == 0:
            self.write('No services found')
            return

        def wkdBooleanTableFormat(weekdays,lang):
            wkds = {
                'fi':('ma','ti','ke','to','pe','la','su'),
                'sv':(u'må','ti','on','to','fre',u'lö',u'sö'),
                'en':('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
            }
            res = []
            debug = []
            start = 0
            end = None
            for i,j in itertools.groupby(weekdays):
                j = list(j)
                if not i:
                    start += len(j)
                    continue
                end = start + len(j)-1
                respart = u'%s-%s' % (wkds[lang][start],wkds[lang][end]) if start!=end else u'%s' % wkds[lang][start]

                res.append(respart)
                start += len(j)

            return ', '.join(res)
        
        if format == 'geojson':
            if len(active_items) > 1 or force_list:
                retjson = {'type': 'FeatureCollection',
                           'features': [{'type': 'Feature',
                           'geometry': ujson.loads(i['jsongeom']),
                           'properties': dict(i['info'],
                           item_id=i['item_id'])} for i in
                           active_items]}
            else:
                retjson = {'type': 'Feature',
                           'geometry': ujson.loads(active_items[0]['jsongeom']),
                           'properties': dict(active_items[0]['info'], item_id=active_items[0]['item_id'])
                           }
            self.set_header("Content-Type", 'application/json; charset="utf-8"')                           
            self.write(ujson.dumps(retjson))
        elif format == 'navici':
            csvdata = cStringIO.StringIO()
            kmldata = cStringIO.StringIO()
            kmldata.write(u'''<?xml version="1.0" encoding="utf-8" ?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document id="root_doc">
<Folder><name>doc</name>''')
            gid = 1
            csvw = csv.writer(csvdata, encoding='utf-8',delimiter=';',quotechar='"')
            csvw.writerow((u'Alueen numero',u'Alueen nimi',u'Lähtöpaikan selite fi',u'Lähtöpaikan selite sv',u'Lähtöpaikan selite en',u'Määränpään selite fi',u'Määränpään selite sv',u'Määränpään selite en',
            u'Selite fi',u'Selite sv',u'Selite en',
            u'Ajopäivät fi',u'Ajopäivät sv',u'Ajopäivät en',
            u'Aikataulu fi',u'Aikataulu sv',u'Aikataulu en',
            u'Lisäpalvelut fi',u'Lisäpalvelut sv',u'Lisäpalvelut en',
            u'Hinta fi',u'Hinta sv',u'Hinta en',
            u'Tilausohje fi',u'Tilausohje sv',u'Tilausohje en',
            u'Kunta fi',u'Kunta sv',
            u'Esteettömyys',u'Liikennöitsijä',u'Puhelinnumero',u'Alkamispäivä',u'Päättymispäivä'))
            for i in active_items:

                for kg in i['kmlgeoms']:
                    kmldata.write(u'''<Placemark id="%s">%s</Placemark>''' % (gid,kg))
                    csvw.writerow((
                        gid,i['info']['lang']['fi']['name'],
                        i['info']['lang']['fi']['startdesc'],
                        i['info']['lang']['sv']['startdesc'],
                        i['info']['lang']['en']['startdesc'],
                        i['info']['lang']['fi']['enddesc'],
                        i['info']['lang']['sv']['enddesc'],
                        i['info']['lang']['en']['enddesc'],
                        i['info']['lang']['fi']['desc'],
                        i['info']['lang']['sv']['desc'],
                        i['info']['lang']['en']['desc'],
                        wkdBooleanTableFormat(i['info']['weekdays'],'fi'),
                        wkdBooleanTableFormat(i['info']['weekdays'],'sv'),
                        wkdBooleanTableFormat(i['info']['weekdays'],'en'),
                        ', '.join(('%(start_time)s - %(end_time)s (%(start_date)s - %(end_date)s)' % v for v in i['info']['valid'])),
                        ', '.join(('%(start_time)s - %(end_time)s (%(start_date)s - %(end_date)s)' % v for v in i['info']['valid'])),
                        ', '.join(('%(start_time)s - %(end_time)s (%(start_date)s - %(end_date)s)' % v for v in i['info']['valid'])),                        
                        i['info']['lang']['fi']['adds'],
                        i['info']['lang']['sv']['adds'],
                        i['info']['lang']['en']['adds'],
                        i['info']['lang']['fi']['price'],
                        i['info']['lang']['sv']['price'],
                        i['info']['lang']['en']['price'],
                        i['info']['lang']['fi']['orddesc'],
                        i['info']['lang']['sv']['orddesc'],
                        i['info']['lang']['en']['orddesc'],
                        '',
                        '',
                        i['info']['accessible'],                                                                      
                        i['info']['agency'] if 'agency' in i['info'] else None,                                                                      
                        i['info']['phone'] if 'phone' in i['info'] else None,
                        datetime.datetime.fromtimestamp(i['minstart']).strftime('%d.%m.%Y'),
                        datetime.datetime.fromtimestamp(i['maxend']).strftime('%d.%m.%Y'),
                    ))
                    gid+=1
            kmldata.write(u'''</Folder></Document></kml>''')
            kmldata.seek(0)

            csvdata.seek(0)


            ozfb = cStringIO.StringIO()
            ozf = zipfile.ZipFile(ozfb,'w')
            ozf.writestr('doc.kml',kmldata.read())
            ozf.writestr('info.csv',csvdata.read())
            ozf.close()

            ozfb.seek(0)
            self.set_header("Content-Type", 'application/zip')
            self.set_header("Content-Disposition", "attachment; filename=all.zip")
            self.write(ozfb.read())
            return     
        else:
            self.write('Unknown format')


        # self.write(pprint.pformat(active_items))

			