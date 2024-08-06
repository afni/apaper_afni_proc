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

### General note on scripts

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
  on a desktop
The user primarily executes the "run" script, which itself calls the associated
"do" script one or more times. Each "do-run" pair produces one new data directory
containing a directory per subject of the output results of that processing
stage.

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


### Data description: task FMRI (Ex. 2, and supplements)

The accompanying data can be downloaded+unpacked via:
```
curl -O https://afni.nimh.nih.gov/pub/dist/tgz/demo_apaper_afni_proc_task.tgz
tar -xf demo_apaper_afni_proc_task.tgz
```

The raw data tree for Ex. 2 is located in data_00_basic/, 
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



