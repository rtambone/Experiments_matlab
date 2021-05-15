spikeStruct = loadKSdir(pwd);
singleUnitsID = (spikeStruct.cids(spikeStruct.cgs == 2));
clusters = 36;
spikes(:,1) = spikeStruct.st(spikeStruct.clu == clusters);
spikes(:,2) = spikeStruct.clu(spikeStruct.clu == clusters); 


%%
%load('DIG1.mat')
cfg.thresTTL = 0.5;
cfg.refractaryPeriodTTL = 0.01;
cfg.samplingFrequency = 30000;
dig_supra_thresh = get_ttl_onsets(Dig_inputs, cfg);
eventOnsets = round(dig_supra_thresh./cfg.samplingFrequency, 3); %convert to seconds
eventOnsets = eventOnsets';
