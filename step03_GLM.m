clear
clc

load e


%% Specify

dirFonc = e.getSerie('run').removeEmpty.toJob(1); % trick so that 1 run == 1 subject, to treat each run seperatly, i.e. 1 GLM per run

clear par
par.display = 0;
par.run = 1;

par.rp       = 1;
par.rp_regex = '^multi.*txt';

par.TR = 0.300;

par.mask_thr = 0.80;

onsets = repmat({struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {})},size(dirFonc{1}));


par.file_reg = '^rv_.*nii';

dirStats = e.getSerie('run').removeEmpty.mkdir('stats','model__RP_FD');


job_first_level_specify(dirFonc,dirStats,onsets,par);



%% Estimate

par.write_residuals = 1;

fspm     = fullfile(dirStats,'SPM.mat');
job_first_level_estimate(fspm,par);
