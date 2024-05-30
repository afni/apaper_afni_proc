#!/bin/tcsh

# AP-4: run afni_proc.py for full FMRI processing (Example 4)
#  -> the Desktop version

# This script runs a corresponding do_*.tcsh script for a given
# subj+ses pair. This script loops over subj+ses pairs from basic dir

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 24_ap_ex4_mesurf

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs
set dir_swarm     = ${dir_inroot}/swarms
set dir_basic     = ${dir_inroot}/data_00_basic

# running
set cdir_log      = ${dir_log}/logs_${cmd}
set scr_swarm     = ${dir_swarm}/swarm_${cmd}.txt
set scr_cmd       = ${dir_scr}/do_${cmd}.tcsh

# --------------------------------------------------------------------------

\mkdir -p ${cdir_log}
\mkdir -p ${dir_swarm}

# clear away older swarm script 
if ( -e ${scr_swarm} ) then
    \rm ${scr_swarm}
endif

# --------------------------------------------------------------------------

# get list of all subj IDs for proc
cd ${dir_basic}
set all_subj = ( sub-* )
cd -

cat <<EOF

++ Proc command:  ${cmd}
++ Found ${#all_subj} subj:

EOF

# -------------------------------------------------------------------------
# build swarm command

# loop over all subj
foreach subj ( ${all_subj} )

    # get list of all ses for the subj
    cd ${dir_basic}/${subj}
    set all_ses = ( ses-* )
    cd -

    # loop over all ses
    foreach ses ( ${all_ses} )
        echo "++ Prepare cmd for: ${subj} - ${ses}"

        set log = ${cdir_log}/log_${cmd}_${subj}_${ses}.txt

        # add cmd to swarm script (verbosely, and don't use '-e'); log
        # terminal text.
        echo "tcsh -xf ${scr_cmd} ${subj} ${ses} \\"    >> ${scr_swarm}
        echo "     |& tee ${log}"                       >> ${scr_swarm}
    end
end

# -------------------------------------------------------------------------
# run swarm command
cd ${dir_scr}

echo "++ And start running: ${scr_swarm}"

tcsh ${scr_swarm}
