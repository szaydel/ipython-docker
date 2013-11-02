#!/bin/bash

cd /tmp; wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz -O - | tar xzf -

python distribute-0.6.49/setup.py install; rc=$?

[[ ${rc} -eq 0 ]] && rm -rf distribute-0.6.49 || exit 1

wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | python

pip install supervisor
