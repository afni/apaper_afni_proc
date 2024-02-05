#!/bin/tcsh

# AP-2: run afni_proc.py for full FMRI processing (Example 2)

# Process a single subj pair.

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
set ap_label       = 22_ap_ex2_task


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
set sdir_timing    = ${sdir_basic}/timing
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
set blur_size     = 6       # blur size to apply 
set final_dxyz    = 3.0     # final voxel size (isotropic dim)
set cen_motion    = 0.3     # censor threshold for motion (enorm) 
set cen_outliers  = 0.05    # censor threshold for outlier frac


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

# AP, example 2: task FMRI
# 
# task-pamenc_bold.json shows slice timing of alt+z2 (missing
# from nii.gz) blur in mask, and use higher 6 mm FWHM (voxels are
# 3x3x4)

# NL alignment

afni_proc.py                                                                 \
    -subj_id                  ${subj}                                        \
    -blocks                   tshift align tlrc volreg mask blur scale       \
                              regress                                        \
    -radial_correlate_blocks  tcat volreg regress                            \
    -copy_anat                ${anat_cp}                                     \
    -anat_has_skull           no                                             \
    -anat_follower            anat_w_skull anat ${anat_skull}                \
    -dsets                    ${dset_epi}                                    \
    -tcat_remove_first_trs    0                                              \
    -tshift_opts_ts           -tpattern alt+z2                               \
    -align_unifize_epi        local                                          \
    -align_opts_aea           -giant_move -cost lpc+ZZ -check_flip           \
    -tlrc_base                ${template}                                    \
    -tlrc_NL_warp                                                            \
    -tlrc_NL_warped_dsets     ${dsets_NL_warp}                               \
    -volreg_align_to          MIN_OUTLIER                                    \
    -volreg_align_e2a                                                        \
    -volreg_tlrc_warp                                                        \
    -volreg_warp_dxyz         ${final_dxyz}                                  \
    -volreg_compute_tsnr      yes                                            \
    -mask_epi_anat            yes                                            \
    -blur_size                ${blur_size}                                   \
    -blur_in_mask             yes                                            \
    -regress_stim_times       ${sdir_timing}/times.CONTROL.txt               \
                              ${sdir_timing}/times.TASK.txt                  \
    -regress_stim_labels      CONTROL TASK                                   \
    -regress_stim_types       AM1                                            \
    -regress_basis_multi      'dmUBLOCK(-1)'                                 \
    -regress_motion_per_run                                                  \
    -regress_censor_motion    ${cen_motion}                                  \
    -regress_censor_outliers  ${cen_outliers}                                \
    -regress_compute_fitts                                                   \
    -regress_fout             no                                             \
    -regress_opts_3dD         -jobs 8                                        \
                              -gltsym 'SYM: TASK -CONTROL'                   \
                              -glt_label 1 T-C                               \
                              -gltsym 'SYM: 0.5*TASK +0.5*CONTROL'           \
                              -glt_label 2 meanTC                            \
    -regress_3dD_stop                                                        \
    -regress_reml_exec                                                       \
    -regress_make_ideal_sum   sum_ideal.1D                                   \
    -regress_est_blur_errts                                                  \
    -regress_run_clustsim     no                                             \
    -html_review_style        pythonic

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

