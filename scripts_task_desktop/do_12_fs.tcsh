#!/bin/tcsh

# FS: run FreeSurfer's recon-all and AFNI's @SUMA_Make_Spec_FS.

# Process a single subj. To loop over many subjects, run the 
# corresponding run_*tcsh script.

# This is a Desktop script.  Run it via swarm (see partner run*.tcsh).


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
set sdir_out = ${sdir_fs}
set lab_out  = FS

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_00  = ( ${sdir_anat}/${subj}_*T1w.nii.gz )

# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -disp_num_cpu`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_using} of available ${nthr_avail} threads"


# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

# make output directory
\mkdir -p ${sdir_out}

time recon-all                                                        \
    -all                                                              \
    -3T                                                               \
    -sd        "${sdir_out}"                                          \
    -subjid    "${subj}"                                              \
    -i         "${dset_anat_00}"

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

# compress path (because of recon-all output dir naming): 
#   move output from DIR/${subj}/${subj}/* to DIR/${subj}/*
\mv    ${sdir_out}/${subj}/* ${sdir_out}/.
\rmdir ${sdir_out}/${subj}

@SUMA_Make_Spec_FS                                                    \
    -fs_setup                                                         \
    -NIFTI                                                            \
    -sid       "${subj}"                                              \
    -fspath    "${sdir_out}"

if ( ${status} ) then
    set ecode = 2
    goto COPY_AND_EXIT
endif

echo "++ FINISHED ${lab_out}"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:


if ( ${ecode} ) then
    echo "++ BAD FINISH: ${lab_out} (ecode = ${ecode})"
else
    echo "++ GOOD FINISH: ${lab_out}"
endif

exit ${ecode}

