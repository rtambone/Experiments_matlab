%% prh freely moving

%% Loading data 
%load coordinate database
nose= IDLCresnet50taskNov5shuffle1600000filtered(:,1:2);
nose(:,2)= array2table(600 - table2array(nose(:,2)));   %invert y axis
load('DIG1.mat') %make sure to be in the right dir (extracted data)
spikeStruct = loadKSdir(pwd); %make sure to be in the right dir (spikes data)

%% Set parameters 
singleUnitsID = (spikeStruct.cids(spikeStruct.cgs == 2));

cfg.threshTTL = 0.5;
cfg.refractaryPeriodTTL = 0.01;
cfg.samplingFrequency = 30000;

dig_supra_thresh = get_ttl_onsets(Dig_inputs, cfg);
eventOnsets = round(dig_supra_thresh./cfg.samplingFrequency, 3); %convert to seconds
eventOnsets = eventOnsets';
diffOnsets = diff(eventOnsets);
peakDiffOnsets  = findpeaks(diffOnsets, 0.05);
newVideoStarts = 1;
for idxNewVideo = 1:size(peakDiffOnsets.loc,1)
    newVideoStarts = [newVideoStarts peakDiffOnsets.loc(idxNewVideo)+1];
end

%% Plotting
video= 7; %select the video to be analyzed
start = newVideoStarts(video);
finish = start+9000-1;
positions = [array2table(eventOnsets(start:finish)) nose];  %table with events and coordinates

f= figure;
set(f,'Position',[1907 547 1316 747]);
for idxUnit = 1:size(singleUnitsID,2)
    spikes = [];
    spikes(:,1) = spikeStruct.st(spikeStruct.clu == singleUnitsID(idxUnit));    %select spikes time del cluster idxUnit
    spikes(:,2) = spikeStruct.clu(spikeStruct.clu == singleUnitsID(idxUnit));   %associate that time to the cluster
    ts = spikes(spikes(:,1)>eventOnsets(start) & spikes(:,1) < eventOnsets(finish));    %time of spikes in the video
    
    [map,stats] = FiringMap(positions,ts, 'nbins', [50 50], 'minTime', 0.1, 'smooth', 1.5,  'minSize', 5, 'minPeak', 0.5);
    subplot(4, 5, idxUnit)
    PlotColorMap(map.rate, map.time)
    axis square
    colorbar
end
exportgraphics(f, 'firing_map_I.png', 'Resolution', 300)