clear
clc

load e

dirFonc = e.getSerie('run').removeEmpty.toJob(1);



dirStats = e.getSerie('run').removeEmpty.mkdir('stats','model__RP_FD');

job = repmat({''},size(dirStats));

job = strcat(job,'export FSLOUTPUTTYPE=NIFTI; fslmerge -tr ');
job = strcat(job," ");
job = strcat(job,dirStats);
job = strcat(job,'clean.nii');
job = strcat(job," ");
job = strcat(job,dirStats);
job = strcat(job,'Res_*.nii');
job = strcat(job,' 0.300');
job

clear par
par.sge = 0;
par.workflow_qsub = 0;
par.jobname = 'fslmerge_3D_to_4D';
par.run = 1;

do_cmd_sge(job,par);

