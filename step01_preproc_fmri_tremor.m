clear
clc

%% Prepare paths and regexp

maindir = '/mnt/data/benoit/protocol/BIOMRI-CADA/fmri';


par.redo= 0;
par.run = 1;
par.pct = 0;
par.sge = 0;


%% Get files paths

e = exam(maindir,'nifti','BIOMRI_CADA'); 


% T1
e.addSerie('3DT1_mprage_1iso_ipat2$','anat_T1' ,1)
e.getSerie('anat').addVolume('^v.*nii','v')

% Run : Exec
e.addSerie('stim2s_run\d{2}$', 'run_2s', 4)
e.addSerie('stim10s_run\d{2}$', 'run_10s', 1)
e.getSerie('run').addVolume('^v.*nii','v',1)

% Unzip if necessary (with PCT ?)
e.unzipVolume(par);

e.reorderSeries('name'); % mostly useful for topup, that requires pairs of (AP,PA)/(PA,AP) scans

e.explore


%% Segment anat with cat12

par.subfolder = 0;         % 0 means "do not write in subfolder"
par.biasstr   = 0.5;
par.accstr    = 0.5;
par.WM        = [1 0 1 0]; %                          (wp2*)     /                        (mwp2*)     /              (p2*)     /                            (rp2*)
par.CSF       = [1 0 1 0]; %                          (wp3*)     /                        (mwp3*)     /              (p3*)     /                            (rp3*)
par.TPMC      = [1 0 1 0]; %                          (wp[456]*) /                        (mwp[456]*) /              (p[456]*) /                            (rp[456]*)
par.label     = [1 0 0] ;  % native (p0*)  / normalize (wp0*)  / dartel (rp0*)       This will create a label map : p0 = (1 x p1) + (3 x p2) + (1 x p3)
par.bias      = [1 1 0] ;  % native (ms*)  / normalize (wms*)  / dartel (rms*)       This will save the bias field corrected  + SANLM (global) T1
par.las       = [0 0 0] ;  % native (mis*) / normalize (wmis*) / dartel (rmis*)      This will save the bias field corrected  + SANLM (local) T1
par.warp      = [1 1];     % Warp fields  : native->template (y_*) / native<-template (iy_*)
par.doSurface = 0;
par.doROI     = 0;         % Will compute the volume in each atlas region
par.jacobian  = 0;         % Write jacobian determinant in normalize space

anat = e.gser('anat_T1').gvol('^v');
job_do_segmentCAT12(anat,par);

par.jobname = 'zipWMCSF';
e.gser('anat_T1').gvol('^wp[23]').zip_and_keep(par);
par = rmfield(par,'jobname');


%% Preprocess fMRI runs

%realign and reslice
par.type = 'estimate_and_reslice';
ffunc_nm = e.getSerie('run').getVolume('^v');
j_realign_reslice_nm = job_realign(ffunc_nm,par);

%coregister mean fonc on brain_anat
fanat = e.getSerie('anat_T1').getVolume('^p0');
fmean = e.getSerie('run').getVolume('^meanv'); fmean = fmean(:,1); % use the mean of the run1 to estimate the coreg
fo    = e.getSerie('run').getVolume('^rv');
par.type = 'estimate';
par.jobname = 'spm_coreg_epi2anat';
j_coregister=job_coregister(fmean,fanat,fo,par);
par = rmfield(par,'jobname');

% coregister WM & CSF on functionnal (using the warped mean)
if isfield(par,'prefix'), par = rmfield(par,'prefix'); end
ref = e.getSerie('run');
ref = ref(:,1).getVolume('^meanv'); % first acquired run (time)
src = e.getSerie('anat_T1').getVolume('^p2');
oth = e.getSerie('anat_T1').getVolume('^p3');
par.type = 'estimate_and_write';
par.jobname = 'spm_coreg_wmcsf2epi';
job_coregister(src,ref,oth,par);
par = rmfield(par,'jobname');


%% Save objects

save('e','e')

