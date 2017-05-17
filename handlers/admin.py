#coding: utf-8
from base import BaseHandler
import pprint
import time
import datetime
import json
import tornado.web
from collections import OrderedDict
import passlib.utils

class IndexHandler(BaseHandler):
    @tornado.web.authenticated
    def get(self):
        if not self.isAdmin() and not self.isUserAllowedTo('group','any','admin','admin'):
            self.redirect(self.reverse_url('index'))
            return None

        curs = self.cursor

        curs.execute('SELECT * FROM jlusers')

        users = curs.fetchall()


        curs.execute('SELECT * FROM jlgroups')

        groups = curs.fetchall()
        self.render2('admin_index',users=users,groups=groups)



class DeleteUserHandler(BaseHandler):
    def get(self,user_id):
        if not self.isAdmin():
            self.redirect(self.reverse_url('index'))
            return None

        try:
            user_id = int(user_id)
        except ValueError:
            self.write('Virheellinen käyttäjän tunnus')
            return False

        curs = self.cursor

        curs.execute('UPDATE jlusers SET valid_to = current_timestamp WHERE user_id = %s',(user_id,))

        self.dbconn.commit()

        self.redirect(self.reverse_url('admin'))


class DeleteGroupHandler(BaseHandler):
    def get(self,group_id):
        if not self.isAdmin():
            self.redirect(self.reverse_url('index'))
            return None

        try:
            group_id = int(group_id)
        except ValueError:
            self.write('Virheellinen ryhmän tunnus')
            return False

        curs = self.cursor

        curs.execute('UPDATE jlgroups SET valid_to = current_timestamp WHERE group_id = %s',(group_id,))

        self.dbconn.commit()

        self.redirect(self.reverse_url('admin'))

class DeleteGroupUserHandler(BaseHandler):
    @tornado.web.authenticated
    def get(self,group_id,user_id):
        curs = self.cursor

        curs.execute('DELETE FROM jluser_groups WHERE group_id = %s AND user_id = %s',(group_id,user_id))

        self.dbconn.commit()

        self.redirect(self.reverse_url('admin-ryhma',group_id))

class AddGroupUserHandler(BaseHandler):
    @tornado.web.authenticated
    def post(self,group_id):       
        curs = self.cursor

        valid = {}
        for k in ('nvalid_from','nvalid_to'):
            dinpval = self.get_argument(k)
            if dinpval != '':
                try:
                    dinpval = datetime.datetime.strptime(dinpval,'%d.%m.%Y')
                    if k == 'valid_to':
                        dinpval = dinpval.replace(hour=23,minute=59)
                except ValueError:
                    errors.append(u'Virheellinen ryhmän voimassaolopäivämäärän muoto')
            else:
                dinpval = None

            valid[k] = dinpval
        
        assert self.get_argument('nuserid') != '-1'
        assert self.get_argument('nrole') != '-1'
        curs.execute('INSERT INTO jluser_groups (user_id,group_id,valid_from,valid_to,role) VALUES (%s,%s,%s,%s,%s)',(
            self.get_argument('nuserid'),
            group_id,
            valid['nvalid_from'],
            valid['nvalid_to'],
            self.get_argument('nrole')
        ))

        self.dbconn.commit()
        self.redirect(self.reverse_url('admin-ryhma',group_id))

class GroupHandler(BaseHandler):
    @tornado.web.authenticated
    def get(self,group_id=None,errors=[]):

        curs = self.cursor

        group = {}
        members = []

        potential_members = []
        
        if group_id:
            curs.execute('SELECT * FROM jlgroups WHERE group_id = %s',(group_id,))
            group = curs.fetchone()

            curs.execute('SELECT ug.*,u.name FROM jluser_groups ug LEFT JOIN jlusers u ON ug.user_id=u.user_id WHERE ug.group_id = %s',(group_id,))
            members = curs.fetchall()

            curs.execute('SELECT user_id,name FROM jlusers WHERE user_id NOT IN (SELECT user_id FROM jluser_groups WHERE group_id = %s)',(group_id,))
            potential_members = curs.fetchall()

        self.render2('admin_ryhma',group=group,members=members,potential_members=potential_members,errors=errors)


    @tornado.web.authenticated
    def post(self,group_id=None):
        if not self.isAdmin():
            self.redirect(self.reverse_url('index'))
            return None

        errors = []

        group = {}

        if group_id:
            group['group_id'] = group

        group['name'] = self.get_argument('groupname')       

        for k in ('valid_from','valid_to'):
            dinpval = self.get_argument(k)
            if dinpval != '':
                try:
                    dinpval = datetime.datetime.strptime(dinpval,'%d.%m.%Y')
                    if k == 'valid_to':
                        dinpval = dinpval.replace(hour=23,minute=59)
                except ValueError:
                    errors.append(u'Virheellinen ryhmän voimassaolopäivämäärän muoto')
            else:
                dinpval = None

            group[k] = dinpval


        if len(errors) > 0:
            self.get(group_id,errors)
            return None


        curs=self.cursor
        if group_id:
            curs.execute('UPDATE jlgroups SET name=%s,valid_to=%s,valid_from=%s WHERE group_id=%s',(group['name'],group['valid_to'],group['valid_from'],group_id))
        else:
            curs.execute('INSERT INTO jlgroups (name,valid_to,valid_from) VALUES (%s,%s,%s) RETURNING group_id',(group['name'],group['valid_to'],group['valid_from']))
            group_id = curs.fetchone()['group_id']

        self.dbconn.commit()

        self.redirect(self.reverse_url('admin-ryhma',group_id))
        
class UserHandler(BaseHandler):
    @tornado.web.authenticated
    def get(self,user_id=None,errors=[]):
        if not self.isAdmin():
            self.redirect(self.reverse_url('index'))
            return None

        curs = self.cursor

        if user_id:
            curs.execute('SELECT * FROM jlusers WHERE user_id = %s',(user_id,))
            user = curs.fetchone()

            curs.execute('SELECT ug.*,g.name FROM jluser_groups ug LEFT JOIN jlgroups g ON ug.group_id = g.group_id WHERE ug.user_id = %s',(user_id,))
            groups = curs.fetchall()

            authorizations = self.application.security.getUserAuthorizations(user_id)

        else:
            user = {}
            groups = []
            authorizations = []


        curs.execute('SELECT * FROM jlgroups WHERE valid_from IS NOT NULL AND valid_from < current_timestamp AND (valid_to IS NULL OR (valid_to IS NOT NULL AND valid_to > current_timestamp))')
        avail_groups = curs.fetchall()

        self.render2('admin_avain',user=user,authorizations=authorizations,groups=groups,avail_groups=avail_groups,errors=errors)
        

    @tornado.web.authenticated
    def post(self,user_id=None):
        if not self.isAdmin():
            self.redirect(self.reverse_url('index'))
            return None


        errors = []

        user = {}

        genavain = self.get_argument('genavain',None) == 'on'

        if user_id:
            user['user_id'] = user_id
        else:
            genavain = True


        user['username'] = self.get_argument('username',None)
        user['name'] = self.get_argument('name')
        user['role'] = self.get_argument('role',None)


        for k in ('valid_from','valid_to'):
            dinpval = self.get_argument(k)
            if dinpval != '':
                try:
                    dinpval = datetime.datetime.strptime(dinpval,'%d.%m.%Y')
                    if k == 'valid_to':
                        dinpval = dinpval.replace(hour=23,minute=59)
                except ValueError:
                    errors.append(u'Virheellinen ryhmän voimassaolopäivämäärän muoto')
            else:
                dinpval = None

            user[k] = dinpval

        groups = []

        try:
            groups = zip(
                (int(k) for k in self.request.arguments['groupid']),
                (r for r in self.request.arguments['grouprole']),
                (datetime.datetime.strptime(d,'%d.%m.%Y').replace(hour=00,minute=00) if d != '' else None for d in self.request.arguments['groupfrom']),
                (datetime.datetime.strptime(d,'%d.%m.%Y').replace(hour=23,minute=59) if d != '' else None for d in self.request.arguments['groupto'])
                )
        except ValueError:
            errors.append(u'Virheellinen päivämäärän muoto ryhmien tiedoissa')
        except KeyError:
            pass

        if len(errors) > 0:
            self.get(user_id,errors)
            return None

        key = None
        keyhash = None
        if genavain:
            key,keyhash = self.__generateKey()


        self.write(pprint.pformat((key,keyhash)))


        curs = self.cursor
        if user_id:
            if not key:
                curs.execute('UPDATE jlusers SET name=%s,valid_from=%s,valid_to=%s,role=%s WHERE user_id=%s',(user['name'],user['valid_from'],user['valid_to'],user['role'],user_id))
            else:
                curs.execute('UPDATE jlusers SET name=%s,valid_from=%s,valid_to=%s,role=%s,passkey=%s WHERE user_id=%s',(user['name'],user['valid_from'],user['valid_to'],user['role'],keyhash,user_id))
        else:
            key,keyhash = self.__generateKey()
            curs.execute('INSERT INTO jlusers (username,name,passkey,valid_from,valid_to,role) VALUES (%s,%s,%s,%s,%s,%s) RETURNING user_id',(user['username'],user['name'],keyhash,user['valid_from'],user['valid_to'],user['role']))
            
            user_id = curs.fetchone()['user_id']

        if user_id:
            curs.execute('DELETE FROM jluser_groups WHERE user_id = %s',(user_id,))

        for g in groups:
            curs.execute('INSERT INTO jluser_groups (user_id,group_id,role,valid_from,valid_to) VALUES (%s,%s,%s,%s,%s)',(user_id,g[0],g[1],g[2],g[3]))

        self.dbconn.commit()

        self.render2('admin_avain_done',key=key,user=user)


    def __generateKey(self):
        key = self.application.security.generatePassword(8)
        keyhash = self.application.security.generatePasswordHash(key)

        return key,keyhash
