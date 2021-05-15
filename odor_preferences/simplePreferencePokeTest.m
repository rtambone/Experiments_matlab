clc
clear

%% Initialize board
% sensorArduino = arduino(findFirstArduinoPort(), 'Uno');
sensorArduino = arduino();


%% Wiring

IRdetectorPin_1 = 'D4'; %beam detector attached to this pin
IRledPin_1 = 'D3'; %emitter led attached to this pin
IRdetectorPin_2 = 'D6'; %beam detector attached to this pin
IRledPin_2 = 'D5'; %emitter led attached to this pin

valvePin1 = 'D10';
valvePin2 = 'D11';

LED_1 = 'D12'; %probe port 1
LED_2 = 'D13'; %probe port 2


%% Set up
configurePin(sensorArduino,IRledPin_1,'DigitalOutput');
configurePin(sensorArduino,IRdetectorPin_1,'DigitalInput');
configurePin(sensorArduino,IRdetectorPin_1,'Pullup');
configurePin(sensorArduino,IRledPin_2,'DigitalOutput');
configurePin(sensorArduino,IRdetectorPin_2,'DigitalInput');
configurePin(sensorArduino,IRdetectorPin_2,'Pullup');
configurePin(sensorArduino,valvePin1,'DigitalOutput');
configurePin(sensorArduino,valvePin2,'DigitalOutput');

configurePin(sensorArduino,LED_1,'DigitalOutput');
configurePin(sensorArduino,LED_2,'DigitalOutput');

writeDigitalPin(sensorArduino,IRledPin_1, 1);
writeDigitalPin(sensorArduino,IRledPin_2, 1);
writeDigitalPin(sensorArduino,LED_1, 0);
writeDigitalPin(sensorArduino,LED_2, 0);
writeDigitalPin(sensorArduino,valvePin1, 0);
writeDigitalPin(sensorArduino,valvePin2, 0);

%% Experimental variables

finish=false;
stimulus1 = 0;
nosePoke1 = 0;
stimulus2 = 0;
nosePoke2 = 0;


lastDebounceTime = 0;  %the last time the output pin was toggled
debounceDelay = 50;    %the debounce time; increase if the output flickers
priorState1 = 0;
priorState2 = 0;


log.logStimuliElapsedTimes.stimulus_1 = nan(1000, 1);
log.logStimuliElapsedTimes.stimulus_2 = nan(1000, 1);
log.onsets.stimulus_1 = nan(1000, 1);
log.onsets.stimulus_2 = nan(1000, 1);

counter_1 = 0;
counter_2 = 0;

totalTime1 = 0;
totalTime2 = 0;


%% Run experiment
folderName = uigetdir;
mouseName = inputdlg('Enter subject name:');
sessionName = inputdlg('Enter session:');
fileName = [mouseName{1} '_' sessionName{1} '.mat'];
readygo = questdlg('Start experiment?', 'Start Acquisition', ...
    'Cancel', 'Start', 'Start');

%
if strcmp(readygo, 'Start')
    FS = stoploop('Stop Acquisition');
    log.startTime = clock;
    t00 = tic;
    origine = round(toc(t00)*1000);

    t01 = tic;
    t02 = tic;
    j = 0;

    log.onsetRecording = origine;

    while ~finish
        
%         writeDigitalPin(sensorArduino,LED_1, 1);
%         writeDigitalPin(sensorArduino,LED_2, 0);
%         pause(1);
%         writeDigitalPin(sensorArduino,LED_1, 0);
%         writeDigitalPin(sensorArduino,LED_2, 1);
%         pause(1);


        
        elapsedTime1 = round(toc(t01)*1000);
        if elapsedTime1 > debounceDelay
            if (readDigitalPin(sensorArduino, IRdetectorPin_1) == 0)
                if priorState1 == 1
                    counter_1 = counter_1 + 1;
                    elapsedTime1 = round(toc(t1)*1000)
                    log.logStimuliElapsedTimes.stimulus_1(counter_1) = elapsedTime1;
                    totalTime1 = totalTime1 + elapsedTime1;
                    writeDigitalPin(sensorArduino,LED_1, 0);
                    writeDigitalPin(sensorArduino,valvePin1, 0);
                    priorState1 = 0;
                end
                t01 = tic;
            else
                if priorState1 == 0
                    nosePoke1 = nosePoke1 + 1
                    inizio1 = round(toc(t00)*1000);
                    writeDigitalPin(sensorArduino,LED_1, 1);
                    writeDigitalPin(sensorArduino,valvePin1, 1);
                    priorState1 = 1;
                    t1 = tic;
                    log.onsets.stimulus1(nosePoke1) = inizio1;
                    
                end
                t01 = tic;
            end
        end
        elapsedTime2 = round(toc(t02)*1000);
        if elapsedTime2 > debounceDelay
            if (readDigitalPin(sensorArduino, IRdetectorPin_2) == 0)
                if priorState2 == 1
                    counter_2 = counter_2 + 1;
                    elapsedTime2 = round(toc(t2)*1000)
                    log.logStimuliElapsedTimes.stimulus_2(counter_2) = elapsedTime2;
                    totalTime2 = totalTime2 + elapsedTime2;
                    writeDigitalPin(sensorArduino,LED_2, 0);
                    writeDigitalPin(sensorArduino,valvePin2, 0);
                    priorState2 = 0;
                end
                t02 = tic;
            else
                if priorState2 == 0
                    nosePoke2 = nosePoke2 + 1
                    inizio2 = round(toc(t00)*1000);
                    writeDigitalPin(sensorArduino,LED_2, 1);
                    writeDigitalPin(sensorArduino,valvePin2, 1);
                    priorState2 = 1;
                    t2 = tic;
                    log.onsets.stimulus2(nosePoke2) = inizio2;
                end
                t02 = tic;
            end
        end
        
       
        
        if FS.Stop()
            break
        end
        
    end
    FS.Clear();
end

log.endRecording = round(toc(t00)*1000);

log.endTime = clock;
log.numberOfPokes.stimulus1 = nosePoke1;
log.numberOfPokes.stimulus2 = nosePoke2;

log.totalInvestigationTime.stimulus1 = totalTime1;
log.totalInvestigationTime.stimulus2 = totalTime2;

if isnan(log.logStimuliElapsedTimes.stimulus_1(1))
    log.InvestigationTimePerPoke.stimulus1.mean = 0;
    log.InvestigationTimePerPoke.stimulus1.std = 0;
else
    log.InvestigationTimePerPoke.stimulus1.mean = nanmean(log.logStimuliElapsedTimes.stimulus_1);
    log.InvestigationTimePerPoke.stimulus1.std = nanstd(log.logStimuliElapsedTimes.stimulus_1);
end

if isnan(log.logStimuliElapsedTimes.stimulus_2(1))
    log.InvestigationTimePerPoke.stimulus2.mean = 0;
    log.InvestigationTimePerPoke.stimulus2.std = 0;
else
    log.InvestigationTimePerPoke.stimulus2.mean = nanmean(log.logStimuliElapsedTimes.stimulus_2);
    log.InvestigationTimePerPoke.stimulus2.std = nanstd(log.logStimuliElapsedTimes.stimulus_2);
end

stringa1 = sprintf('Number of pokes in hole 1: %d', nosePoke1);
stringa2 = sprintf('Number of pokes in hole 2: %d', nosePoke2);
disp(stringa1);
disp(stringa2);

stringa1 = sprintf('Time spent investigating odor 1: %d ms', totalTime1);
stringa2 = sprintf('Time spent investigating odor 1: %d ms', totalTime2);
disp(stringa1);
disp(stringa2);

preferenceIndexOdor = (totalTime1 - totalTime2) / (totalTime1 + totalTime2);
stringa = sprintf('Odor Preference Index (1 = odor 1; -1 = odor 2) = %d', preferenceIndexOdor');
disp(stringa);
log.preferenceIndexOdor = preferenceIndexOdor;


inizio = log.onsetRecording;
fine = log.endRecording;
timeline = zeros(1,(fine-inizio)+1);
if nosePoke1 > 0
    for idxPokes = 1:nosePoke1
        iniziato = log.onsets.stimulus1(idxPokes);
        durato = log.logStimuliElapsedTimes.stimulus_1(idxPokes);
        timeline(iniziato:iniziato+durato) = 1;
    end
end
if nosePoke2 > 0
    for idxPokes = 1:nosePoke2
        iniziato = log.onsets.stimulus2(idxPokes);
        durato = log.logStimuliElapsedTimes.stimulus_2(idxPokes);
        timeline(iniziato:iniziato+durato) = -1;
    end
end

log.timeline = timeline;


% fileName = ['Experiment_Log.mat'];
currentFolder = pwd;
cd(folderName)
save(fileName, 'log')
cd(currentFolder)


%%
figure;
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gcf,'Position',[150 40 1700 960]);
subplot(2,3,[1 3])
plot(0:1/1000:(length(log.timeline)-1)./1000, log.timeline, 'r', 'linewidth', 3)
ylim([-1.5 1.5])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 14)
set(gca,'YColor','w')
set(gca,'YTick',[])
set(gca,'YTickLabel',[])

xlabel('Time (s)')
subplot(2,3,4)
bar([log.numberOfPokes.stimulus1 log.numberOfPokes.stimulus2])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 14)
ylabel('Number Of Nose Pokes')
subplot(2,3,5)
bar([log.totalInvestigationTime.stimulus1 log.totalInvestigationTime.stimulus2])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 14)
ylabel('Time Spent Per Odor (ms)')
subplot(2,3,6)
errorbar([1 2], [log.InvestigationTimePerPoke.stimulus1.mean log.InvestigationTimePerPoke.stimulus2.mean],...
    [sqrt(log.InvestigationTimePerPoke.stimulus1.std/log.numberOfPokes.stimulus1) sqrt(log.InvestigationTimePerPoke.stimulus2.std/log.numberOfPokes.stimulus2)])
xlim([0 3])
top = max([log.InvestigationTimePerPoke.stimulus1.mean log.InvestigationTimePerPoke.stimulus2.mean]) + 100;
bot = min([log.InvestigationTimePerPoke.stimulus1.mean log.InvestigationTimePerPoke.stimulus2.mean]) - 100;
if bot < 0
    bot = 0;
end
ylim([bot top])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 14)
stringa = sprintf('Odor Preference Index = %0.1f', log.preferenceIndexOdor');
title(stringa)
ylabel('Mean Investigation Time Per Poke (ms)')

%%
clear a
