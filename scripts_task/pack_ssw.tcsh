#!/bin/tcsh

echo "++ Pack up SSW images"

cd ..

set dir  = data_13_ssw
set otgz = qc_${dir}.tgz
echo "++ Pack up all dir: ${dir} -> ${otgz}"
tar -zcf ${otgz} ${dir}/sub-*/*jpg

cd -

echo "++ Done"
