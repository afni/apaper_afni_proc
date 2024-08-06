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

In each demo download, a pair of scripts directories is provided:
* `scripts_*_biowulf` : scripts set up for batch processing on a high
  performance cluster that uses Slurm as its workload manager (specifically,
  `swarm` to submit multiple jobs simultaneously), which is called Biowulf
  at NIH where the processing was originally performed.
* `scripts_*_desktop` : scripts set up for batch processing on a standard
  desktop running Linux or macOS.



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



