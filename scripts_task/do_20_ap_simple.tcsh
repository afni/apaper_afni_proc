#!/bin/tcsh

# AP simple: run afni_proc.py for full FMRI processing (for initial QC)

# Process a single subj+ses pair.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ----------------------------- biowulf-cmd ---------------------------------
# load modules
source /etc/profile.d/modules.csh
module load afni

# set N_threads for OpenMP
setenv OMP_NUM_THREADS $SLURM_CPUS_ON_NODE

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
#set ses            = $2
set ap_label       = 20_ap_simple


# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
#set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_ap         = ${dir_inroot}/data_${ap_label}

# subject directories
set sdir_basic     = ${dir_basic}/${subj}  #/${ses}
set sdir_func      = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
#set sdir_fs        = ${dir_fs}/${subj}  #/${ses}
#set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}  #/${ses}
set sdir_ap        = ${dir_ap}/${subj}  #/${ses}

# supplementary directories and info
set dir_suppl      = ${dir_inroot}/supplements
set template       = ${dir_suppl}/MNI152_2009_template_SSW.nii.gz

# set output directory
set sdir_out = ${sdir_ap}
set lab_out  = AP

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

setenv AFNI_COMPRESSOR GZIP

# dataset inputs
set task_label    = task-pamenc

set epi_radix     = ${sdir_func}/${subj}  #_${ses}
set dset_epi      = ( ${epi_radix}_${task_label}_bold.nii* )

set anat_cp       = ( ${sdir_ssw}/anatSS.${subj}.nii* )
set anat_skull    = ( ${sdir_ssw}/anatU.${subj}.nii* )

set dsets_NL_warp = ( ${sdir_ssw}/anatQQ.${subj}.nii*         \
                      ${sdir_ssw}/anatQQ.${subj}.aff12.1D     \
                      ${sdir_ssw}/anatQQ.${subj}_WARP.nii*  )

# control variables
set nt_rm         = 0       # number of time points to remove at start
#set blur_size     = 6       # blur size to apply 
#set final_dxyz    = 3.0     # final voxel size (isotropic dim)
#set cen_motion    = 0.3     # censor threshold for motion (enorm) 
#set cen_outliers  = 0.05    # censor threshold for outlier frac


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

# make output directory and go to it
\mkdir -p ${sdir_out}
cd ${sdir_out}

# create command script
set run_script = ap.cmd.${subj}

cat << EOF >! ${run_script}

# AP, run simple
#
# single echo FMRI, simple processing for initial QC
# anatomical has skull on

ap_run_simple_rest.tcsh                                                \
    -run_ap                                                            \
    -subjid    ${subj}                                                 \
    -nt_rm     ${nt_rm}                                                \
    -anat      ${anat_skull}                                           \
    -epi       ${dset_epi}                                             \
    -template  ${template}

EOF

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif


# execute AP command to make processing script
tcsh -xef ${run_script} |& tee output.ap.cmd.${subj}

if ( ${status} ) then
    set ecode = 2
    goto COPY_AND_EXIT
endif


# execute the proc script, saving text info
time tcsh -xef proc.${subj} |& tee output.proc.${subj}

if ( ${status} ) then
    set ecode = 3
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

