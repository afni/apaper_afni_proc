#!/bin/tcsh

# AP-9: run afni_proc.py for full FMRI processing (Example 9)
# -> variation of Ex. 2, adding in BIDS-Deriv output
#  -> the Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj. It also loops over many subjects.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 39_ap_ex9_task_bder

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
    echo "++ Prepare cmd for: ${subj}"

    set log = ${cdir_log}/log_${cmd}_${subj}.txt

    # add cmd to swarm script (verbosely, and don't use '-e'); log
    # terminal text.
    echo "tcsh -xf ${scr_cmd} ${subj} \\"    >> ${scr_swarm}
    echo "     |& tee ${log}"                >> ${scr_swarm}
end

# -------------------------------------------------------------------------
# run swarm command
cd ${dir_scr}

echo "++ And start swarming: ${scr_swarm}"

swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm,quick                                         \
    --threads-per-process=16                                       \
    --gb-per-process=10                                            \
    --time=03:59:00                                                \
    --gres=lscratch:10                                             \
    --logdir=${cdir_log}                                           \
    --job-name=job_${cmd}                                          \
    --merge-output                                                 \
    --usecsh
