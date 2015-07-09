#!/bin/bash

PYENV_DIR=/var/local/ckan/default/pyenv
. ${PYENV_DIR}/bin/activate
cd ${PYENV_DIR}/src/ckan && paster celeryd -c config.ini
