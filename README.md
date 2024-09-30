# apaper_afni_proc
Scripts to accompany FMRI processing examples using AFNI's afni_proc.py, 
for the accompanying paper:
+   Reynolds RC, Glen DR, Chen G, Saad ZS, Cox RW, Taylor PA (2024). 
    Processing, evaluating and understanding FMRI data with afni_proc.py.  
    arXiv:2406.05248 [q-bio.NC]
    https://arxiv.org/abs/2406.05248

Full sets of the data and processing scripts (which themselves are copies
of script directories in the present git repository, from the time of 
publication) are available for download, as described below. There are two
downloadable demos provided: one for resting state FMRI (acquired with multiple
echos, and including processing for both single- and multi-echo FMRI) 
and one for task-based FMRI.

### How to use the scripts (general organization and guidance)

##### Desktop and HPC scripts

In each demo download, a pair of script directories is provided:
* `scripts_*_biowulf` : scripts set up for batch processing on a high
  performance cluster that uses Slurm as its workload manager (specifically,
  `swarm` to submit multiple jobs simultaneously), which is called Biowulf
  at NIH where the processing was originally performed.
* `scripts_*_desktop` : scripts set up for batch processing on a standard
  desktop running Linux or macOS.

In each download, only one subject's data is provided, but 
the scripts are setup to process a group of subjects with unprocessed 
data organized in the same way. That means there is more "scripty" stuff
to read, rather than just FMRI processing commands, but we hope it is 
useful.

##### Running scripts

In each case, scripts are organized to run in the following way, partitioning
the "what needs to be done per subject" from the "managing the looping over
a group of subjects". Therefore, each stage of processing is controlled by
a pair of scripts, the `do_*.tcsh` and `run_*.tcsh` script, respectively:
* `do_*.tcsh` : do one stage of processing (like nonlinear alignment,
  running FreeSurfer, running afni_proc.py, etc.) on one dataset, whose
  subject ID (and possibly session ID) are input at runtime.
* `run_*.tcsh` : manage having one or more datasets to process, such as
  by looping over all subject (and possibly session) IDs in a directory, and
  either setup a swarm script to run on an HPC or start processing in series
  on a desktop.
   
The user primarily executes the "run" script, which itself calls the associated
"do" script one or more times. Each "do-run" pair produces one new data directory
containing a directory per subject of the output results of that processing
stage.

##### Script and data tree naming

The script names contain a 2-digit number near the beginning, so that a simple `ls` 
in the directory lists them in the approximate order of expected execution. That is, 
`run_03*.tcsh` comes before `run_22*.tcsh`. There are gaps in the numbering, 
to leave room for other stages to be inserted when adapting them. Also, sometimes
the numbering just separates stages that would be run in parallel; for example,
each afni_proc.py example is independent, and these are simply each of the
`run_2*.tcsh` and `run_3*.tcsh` scripts here.

There is a simple string label associated with each number, that remains constant
for both the `do_*.tcsh` and `run_*.tcsh` scripts, as well as the output data
directory.  Thus, `do_03_timing.tcsh` is paired with `run_03_timing.tcsh`, which 
produces `data_03_timing` as the output data tree.

##### Example commands without variables

To simplify reading some of the afni_proc.py commands themselves, we
provide a set of variable-free versions in `example_ap_cmds/`.  Note
that these are also stored within afni_proc.py itself with name keys,
and you can show these directly in the terminal with:

    afni_proc.py -show_examples 'AP publish 3a'
    afni_proc.py -show_examples 'AP publish 3b'
    afni_proc.py -show_examples 'AP publish 3c'
    ...

etc. (see `afni_proc.py -show_example_names` for the complete list of
these and others). These name abbreviations can also be used with the
several helpful `-compare_* ..` options in AP.

### Task FMRI demo (Ex. 2, and supplements)

##### Download

The accompanying data can be downloaded+unpacked via:
```
curl -O https://afni.nimh.nih.gov/pub/dist/tgz/demo_apaper_afni_proc_task.tgz
tar -xf demo_apaper_afni_proc_task.tgz
```

##### Raw data contents

The raw/unprocessed data tree is located in data_00_basic/, 
with the following BIDS file structure (though afni_proc.py 
does not require any particular file structure to run processing):
```
data_00_basic/
|-- dataset_description.json
|-- participants.tsv
|-- README
`-- sub-10506
    |-- anat
    |   |-- sub-10506_T1w.json
    |   `-- sub-10506_T1w.nii.gz
    `-- func
        |-- sub-10506_task-pamenc_bold.json
        |-- sub-10506_task-pamenc_bold.nii.gz
        `-- sub-10506_task-pamenc_events.tsv
```

##### Scripts already run

The following processing script pairs exist in the `scripts*/` directory, and
have already been run so their data directories exist in the distributed demo:
* `*03_timing*` : run `timing_tool.py` to generate timing files from the
  stimulus events TSV
* `*12_fs*` : run FreeSurfer's `recon-all` and AFNI's `@SUMA_Make_Spec_FS`
  on the raw anatomical dataset, to estimate surface meshes and then create
  standardized mesh versions; also creates anatomical parcellations.
* `*13_ssw*` : run `sswarper2` on the raw anatomical dataset, to skullstrip
  (ss) it and to estimate nonlinear alignment (warping) to standard space.
  
NB: a subset of output datasets (trimmed to what is useful for further steps)
might be distributed in some cases, to reduce the download size of the demo. 

##### Scripts to be run

The following processing script pairs exist in the `scripts*/` directory, for
the user to run:
* `*20_ap_simple*` : run a "simple" `afni_proc.py` command on the raw data,
  that requires essentially no options and does only affine alignment to
  template space for quicker processing, but generates a very useful set of
  outputs and QC HTML for investigating the data quickly.
* `*22_ap_ex2_task*` : run the Ex. 2 `afni_proc.py` command for task-based
  FMRI processing. This includes using nonlinear alignment, stimulus timing,
  and more.
* `*40_ap_ex10_task_bder*` : run the (supplementary) Ex. 10 `afni_proc.py`
  command for task-based processing. This is a variation of Ex. 2 that
  includes an output directory in BIDS-Derivative format.

##### Supplementary scripts

* `pack*.tcsh*` : several of the above scripts run programs that create QC output;
  these scripts pack up things like the QC images or QC HTML directories from
  a given output across all subjects and create a compressed tarball, which can be
  more easily moved around.

### Rest FMRI Demo (Ex. 1, 3, 4 and supplements)

The accompanying data can be downloaded+unpacked via:
```
curl -O https://afni.nimh.nih.gov/pub/dist/tgz/demo_apaper_afni_proc_rest.tgz
tar -xf demo_apaper_afni_proc_rest.tgz
```

The raw data tree is located in data_00_basic/, \*\*\*
```
data_00_basic/
`-- sub-005
    `-- ses-01
        |-- anat
        |   `-- sub-005_ses-01_mprage_run-1_T1w.nii.gz
        `-- func
            |-- sub-005_ses-01_acq-blip_dir-match_run-1_bold.nii.gz
            |-- sub-005_ses-01_acq-blip_dir-opp_run-1_bold.nii.gz
            |-- sub-005_ses-01_task-rest_run-1_echo-1_bold.nii.gz
            |-- sub-005_ses-01_task-rest_run-1_echo-2_bold.nii.gz
            |-- sub-005_ses-01_task-rest_run-1_echo-3_bold.nii.gz
            |-- sub-005_ses-01_task-rest_run-1_physio-ECG.txt
            `-- sub-005_ses-01_task-rest_run-1_physio-Resp.txt
```

##### Scripts already run

The following processing script pairs exist in the `scripts*/` directory, and
have already been run so their data directories exist in the distributed demo:
* `*12_fs*` : run FreeSurfer's `recon-all` and AFNI's `@SUMA_Make_Spec_FS`
  on the raw anatomical dataset, to estimate surface meshes and then create
  standardized mesh versions; also creates anatomical parcellations.
* `*13_ssw*` : run `sswarper2` on the raw anatomical dataset, to skullstrip
  (ss) it and to estimate nonlinear alignment (warping) to standard space.
* `*14_physio*` : run `physio_calc.py` on the physiological (cardiac and
  respiratory) time series, to estimate physio regressors for the FMRI
  processing.

NB: a subset of output datasets (trimmed to what is useful for further steps)
might be distributed in some cases, to reduce the download size of the demo. 

##### Scripts to be run

The following processing script pairs exist in the `scripts*/` directory, for
the user to run:
* `*20_ap_simple*` : run a "simple" `afni_proc.py` command on the raw data,
  that requires essentially no options and does only affine alignment to
  template space for quicker processing, but generates a very useful set of
  outputs and QC HTML for investigating the data quickly.
* `*21_ap_ex1_align*` : run Ex. 1's `afni_proc.py` command that basically just
  does the alignment part of FMRI processing, which appropriate concatenation;
  includes blip up/down (B0 inhomogeneity) distortion correction.
* `*23_ap_ex3_vol*` : run Ex. 3's `afni_proc.py` command, which is a fairly
  standard resting state processing case for voxelwise analysis; includes
  physio regressors, GM ROIs from FreeSurfer, and user-specified ROI imports
  for TSNR checks.
* `*24_ap_ex4_mesurf*` : run Ex. 4's `afni_proc.py` command, which processes
  multi-echo (ME) FMRI data and performs surface-based analysis; the tedana-MEICA
  is used to combine echos; blip up/down correction is also performed.
* `*35_ap_ex5_vol*` : run (supplementar) Ex. 5's `afni_proc.py` command,
  which is a variation of Ex. 3 that includes bandpassing; see the draft for
  a discussion of this topic.
* `*36_ap_ex6_vol*` : run (supplementar) Ex. 6's `afni_proc.py` command,
  which is a variation of Ex. 3 that includes local ANATICOR and ventricle
  regressors to the processing; also includes blurring to FWHM.
* `*37_ap_ex7_roi*` : run (supplementar) Ex. 7's `afni_proc.py` command,
  which is a variation of Ex. 3 that performs processing for an ROI-based study;
  primarily, this means not including blurring.
* `*38_ap_ex8_mesurf*` : run (supplementar) Ex. 8's `afni_proc.py` command,
  which is a variation of Ex. 4 that uses OC to combine ME-FMRI echos.
* `*39_ap_ex9_mevol*` : run (supplementar) Ex. 9's `afni_proc.py` command,
  which is a variation of Ex. 3 that processes ME-FMRI in the volume.

##### Supplementary scripts

* `pack*.tcsh*` : several of the above scripts run programs that create QC output;
  these scripts pack up things like the QC images or QC HTML directories from
  a given output across all subjects and create a compressed tarball, which can be
  more easily moved around.



