from geoserver.catalog import Catalog

cat = Catalog('http://localhost:8082/geoserver/rest')
ds = cat.create_datastore('geonode','geonode')
ds.connection_parameters.update(host='localhost', port='5432', database='geonode_data', user='user', passwd='user', dbtype='postgis', schema='public')
try:
    cat.save(ds)
except Exception as e:
    print e

