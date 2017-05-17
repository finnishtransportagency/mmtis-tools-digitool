import pprint

class betaAuthorization:
    def getAuthorizationsForItem(self,target_service,target_resource,target_ident):
        curs = self.cursor()
        
        curs.execute('SELECT a.*,CASE WHEN a.authorized_type = %s THEN u.name ELSE g.name END as authorized_name FROM jlauthorizations a LEFT JOIN jlusers u ON a.authorized_type = %s AND a.authorized_id = u.user_id LEFT JOIN jlgroups g ON a.authorized_type = %s AND a.authorized_id = g.group_id WHERE a.target_service = %s AND a.target_resource = %s AND a.target_ident = %s AND (a.valid_from < current_timestamp AND (a.valid_to IS NULL OR (a.valid_to IS NOT NULL AND a.valid_to > current_timestamp)))',('user','user','group',target_service,target_resource,target_ident))

        authorizations = curs.fetchall()

        return authorizations



    def getUserAuthorizations(self,user_id):
        curs = self.cursor()

        curs.execute('''
            SELECT * FROM jlauthorizations WHERE
            (authorized_type = %s AND authorized_id = %s) OR
            (authorized_type = %s AND authorized_id IN
                (SELECT group_id FROM jluser_groups WHERE user_id = %s AND valid_from < current_timestamp AND (valid_to IS NULL OR valid_to < current_timestamp)))''',
                ('user',user_id,'group',user_id,))
            
        authorizations = curs.fetchall()

        curs.execute('SELECT * FROM jluser_groups WHERE user_id = %s AND role = %s',(user_id,'admin'))

        group_admins = curs.fetchall()

        for g in group_admins:
            authorizations.append({
                'authorized_id':user_id,
                'authorized_type':'user',
                'permission':'admin',
                'target_ident':g['group_id'],
                'target_resource':'group',
                'target_service':'admin',
                'valid_from':g['valid_from'],
                'valid_to':g['valid_to']
            })

        return authorizations
    
    def isAllowedTo(self,service,resource,ident,action,user):
        if user == None:
            return False

        if user['role'] == 'admin':
            return True

        print 'isAllowedTo',service,resource,ident,action,user['username']
        
        allow_table = {
            'read':('read',),
            'edit':('read','edit'),
            'admin':('read','edit','admin')
        }
        for a in user['authorizations']:
            if a['target_service'] != service:
                print 'wrong service',a['target_service'],'!=',service
                continue
            if a['target_resource'] != resource:
                print 'wrong resource',a['target_resource'],'!=',resource
                continue
            
            print 'ident:',ident == 'any',a['target_ident'],unicode(ident),unicode(ident)==unicode(a['target_ident'])
            if ident == 'any' or unicode(ident) == unicode(a['target_ident']):
                print 'action:',action,a['permission'],allow_table[a['permission']],action in allow_table[a['permission']]
                if action in allow_table[a['permission']]:
                    return True
        return False
