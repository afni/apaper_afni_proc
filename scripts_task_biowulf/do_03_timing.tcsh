#!/bin/tcsh

# TIME: run timing_tool.py to make timing file from TSV

# Process a single subj. To loop over many subjects, run the 
# corresponding run_*tcsh script.

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
#set ses            = $2

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_timing     = ${dir_inroot}/data_03_timing
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw

# subject directories
set sdir_basic     = ${dir_basic}/${subj}  #/${ses}
set sdir_func      = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
set sdir_timing    = ${dir_timing}/${subj}  #/${ses}
set sdir_fs        = ${dir_fs}/${subj}  #/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}  #/${ses}

# supplementary directories and info
set dir_suppl      = ${dir_inroot}/supplements
set template       = ${dir_suppl}/MNI152_2009_template_SSW.nii.gz

# set output directory
set sdir_out = ${sdir_timing}
set lab_out  = TIME

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set taskname      = pamenc
set task_label    = task-${taskname}

set file_tsv      = ( ${sdir_func}/${subj}_${task_label}_events.tsv )

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
    set sdir_out = /lscratch/$SLURM_JOBID/${subj}  #_${ses}

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

# make output directory
\mkdir -p ${sdir_out}

timing_tool.py                                                        \
    -multi_timing_ncol_tsv  ${file_tsv}                               \
    -tsv_labels             onset reaction_time trial_type            \
    -tsv_def_dur_label      duration                                  \
    -write_multi_timing     "${sdir_out}/"

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

