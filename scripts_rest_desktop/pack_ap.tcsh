#!/bin/tcsh

echo "++ Pack up APQC HTML dirs per data_ dir"

cd ..

set all_dir = ( data_2* )

foreach dir ( ${all_dir} )
    set otgz   = qc_${dir}.tgz
    echo "++ Pack up dir: ${dir} -> ${otgz}"
    tar -zcf ${otgz} ${dir}/sub-*/ses*/*results/QC_*
end

cd -

echo "++ Done"
