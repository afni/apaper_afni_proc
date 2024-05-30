#!/bin/tcsh

# PHYS: run physio_calc.py to get FMRI regressors from physio
# (card+resp) data.

# Process a single subj+ses pair.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ----------------------------- biowulf-cmd ---------------------------------
# load modules
source /etc/profile.d/modules.csh
module load afni

# set N_threads for OpenMP
setenv OMP_NUM_THREADS $SLURM_CPUS_ON_NODE
# ---------------------------------------------------------------------------

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0

# ---------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_physio     = ${dir_inroot}/data_14_physio

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_func      = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}
set sdir_physio    = ${dir_physio}/${subj}/${ses}

# supplementary directories and info
set dir_suppl      = ${dir_inroot}/supplements
set template       = ${dir_suppl}/MNI152_2009_template_SSW.nii.gz

# set output directory
set sdir_out = ${sdir_physio}
set lab_out  = PHYS

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set task_label  = task-rest_run-1
set physio_card = ${sdir_func}/${subj}_${ses}_${task_label}_physio-ECG.txt
set physio_resp = ${sdir_func}/${subj}_${ses}_${task_label}_physio-Resp.txt

set dset_epi_e2 = ${sdir_func}/${subj}_${ses}_${task_label}_echo-2_bold.nii.gz

# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -disp_num_cpu`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_using} of available ${nthr_avail} threads"

# ----------------------------- biowulf-cmd --------------------------------
# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_out}
    set sdir_out = /lscratch/$SLURM_JOBID/${subj}_${ses}

    # prep for group permission reset
    \mkdir -p ${sdir_BW}
    set grp_own  = `\ls -ld ${sdir_BW} | awk '{print $4}'`
else
    set usetemp  = 0
endif
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

# make output directory and go to it
\mkdir -p ${sdir_out}
cd ${sdir_out}

# create command script
set run_script = run_retrots.txt

cat << EOF >! ${run_script}

# make physio regressors.
# the EPI dataset provides necessary info about TR, number of 
#   time points, etc.

# '-img_* ..' options are for making more convenient QC plots here

physio_calc.py                             \
    -card_file           ${physio_card}    \
    -resp_file           ${physio_resp}    \
    -freq                50                \
    -dset_epi            ${dset_epi_e2}    \
    -dset_slice_pattern  alt+z             \
    -img_line_time       120               \
    -img_figsize         12 6              \
    -out_dir             .                 \
    -prefix              ${subj}_${ses}_${task_label}_physio

EOF

# and run it
tcsh -xf ${run_script} |& tee out.${run_script}

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

echo "++ FINISHED ${lab_out}"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------
# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_out} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_out}"
    echo "          to: ${sdir_BW}"
    \cp -pr   ${sdir_out}/* ${sdir_BW}/.

    # reset group permission
    chgrp -R ${grp_own} ${sdir_BW}
endif
# ---------------------------------------------------------------------------

if ( ${ecode} ) then
    echo "++ BAD FINISH: ${lab_out} (ecode = ${ecode})"
else
    echo "++ GOOD FINISH: ${lab_out}"
endif

exit ${ecode}

