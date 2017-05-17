import passlib.context
import passlib.utils
import psycopg2.extras


import authorization

class LiViBetaSecurity(authorization.betaAuthorization):
    def __init__(self,dbpool):
        self.dbpool = dbpool
        self.pwd_context =  passlib.context.CryptContext(
            schemes=["pbkdf2_sha256", "des_crypt" ],
            default="pbkdf2_sha256",
            all__vary_rounds = 0.1,
            pbkdf2_sha256__default_rounds = 10000)
    
    def __del__(self):
        if hasattr(self,'curs') and not self.curs.closed:
            self.curs.close()
            print 'Cursor closed'
            
        if hasattr(self,'dbconn'):
            self.dbpool.putconn(self.dbconn)
            print 'Connection put away'
        
    def cursor(self):
        if not hasattr(self,'dbconn'):
            self.dbconn = self.dbpool.getconn()
        if not hasattr(self,'curs'):
            self.curs = self.dbconn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        return self.curs

    def generatePasswordHash(self,passkey):
	return self.pwd_context.encrypt(passkey)
    
    def generatePassword(self,pwlen):
        return passlib.utils.generate_password(pwlen)
    
    def verify(self,token,passkey):
        return self.pwd_context.verify(token,passkey)
