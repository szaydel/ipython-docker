#!/bin/bash

PREFIX=/opt/local/anaconda
PKG=Miniconda-2.0.3-Linux-x86_64.sh
wget http://repo.continuum.io/miniconda/$PKG
chmod +x ./$PKG; ./$PKG -b -p $PREFIX

$PREFIX/bin/conda install --yes --file /root/packages.list

rm $PKG /root/packages.list
$PREFIX/bin/pip install --pre ggplot # Python implementation of ggplot.
$PREFIX/bin/pip install --egg --no-deps --pre supervisor
