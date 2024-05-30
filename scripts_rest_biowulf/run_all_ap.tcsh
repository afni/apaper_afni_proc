#!/bin/tcsh


set all_script = ( run_2*.tcsh run_3*.tcsh )
set nscript    = ${#all_script}

echo "++ Found ${nscript} to run:"

foreach script ( ${all_script} )
    echo "   ${script}"
end

echo "++ ... starting them:"

foreach script ( ${all_script} )
    tcsh ${script}
end
