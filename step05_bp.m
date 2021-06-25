clear
clc

load e

dirFonc = e.getSerie('run').toJob(1);

kernel = {'4' '6' '8'};

for k = 1 : length(kernel)
    
    dirStats = e.mkdir('stats',sprintf('model_%s',kernel{k}));
    
    job = repmat({''},size(dirStats));
    
    job = strcat(job,"3dBandpass -prefix ");
    job = strcat(job,dirStats);
    job = strcat(job,sprintf('bp_s%s.nii',kernel{k}));
    job = strcat(job," 0.001 0.1 ");
    job = strcat(job,dirStats);
    job = strcat(job,sprintf('clean_s%s.nii',kernel{k}));
    job
    
    clear par
    par.sge = 1;
    par.workflow_qsub = 0;
    par.jobname = 'afni_3dBandpass';
    
    do_cmd_sge(job,par);
    
end
