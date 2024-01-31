#!/bin/tcsh

# FS: run FreeSurfer's recon-all and AFNI's @SUMA_Make_Spec_FS.
#  -> the Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 12_fs

# labels
set subj          = sub-005
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs
set dir_swarm     = ${dir_inroot}/swarms

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

set log = ${cdir_log}/log_${cmd}_${subj}_${ses}.txt

# run command script (verbosely, and don't use '-e'); log terminal text.
cat <<EOF >> ${scr_swarm}
tcsh -xf ${scr_cmd} ${subj} ${ses} |& tee ${log}
EOF

echo "++ And start swarming: ${scr_swarm}"

swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm                                               \
    --threads-per-process=1                                        \
    --gb-per-process=10                                            \
    --time=12:00:00                                                \
    --gres=lscratch:10                                             \
    --logdir=${cdir_log}                                           \
    --job-name=job_${cmd}                                          \
    --merge-output                                                 \
    --usecsh
