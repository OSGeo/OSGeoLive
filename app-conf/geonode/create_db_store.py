#########################################################################
#
# Copyright (C) 2012 OpenPlans
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#########################################################################

from geoserver.catalog import Catalog

cat = Catalog('http://localhost:8082/geoserver/rest')
ds = cat.create_datastore('geonode','geonode')
ds.connection_parameters.update(host='localhost', port='5432', database='geonode_data', user='user', passwd='user', dbtype='postgis', schema='public')
try:
    cat.save(ds)
except Exception as e:
    print e

