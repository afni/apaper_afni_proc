#!/bin/tcsh

echo "++ Pack up FS images"

cd ..

set dir  = data_12_fs
set otgz = qc_${dir}.tgz
echo "++ Pack up all dir: ${dir} -> ${otgz}"
tar -zcf ${otgz} ${dir}/sub-*/ses*/SUMA/*jpg

cd -

echo "++ Done"
