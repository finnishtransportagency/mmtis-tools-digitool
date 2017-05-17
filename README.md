# Kutsujoukkoliikenne-palvelu
Palvelu tarjoaa digitointityökalun aluemuotoisille kutsuliikennejoukkoliikennepalveluille. Palvelu on tällä hetkellä käytössä Liikennevirastolla osoitteessa http://beta.liikennevirasto.fi/joukkoliikenne/kutsujoukkoliikenne/

## Käyttöönotto
Vaadittavat sovellukset:
* Python 2.7 & pip (https://pip.pypa.io/en/stable/installing/)
* PostgreSQL ja PostGIS

### Asennus
Python moduulit

`pip install -r requirements.txt`

Tietokantarakenne
```sql
createuser -P kutsuliikenne
createdb -O kutsuliikenne kutsuliikenne
psql -f kutsuliikenne.sql kutsuliikenne
```

Käynnistä sovellus

`python kutsuliikenne.py --port=80 --dbname=kutsuliikenne --dbuser=kutsuliikenne --dbpasswd=<salasana>`