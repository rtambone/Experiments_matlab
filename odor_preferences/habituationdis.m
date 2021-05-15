clc
clear

%% Initialize board
% sensorArduino = arduino(findFirstArduinoPort(), 'Uno');
sensorArduino = arduino();


%% Wiring

IRdetectorPin_1 = 'D4'; %beam detector attached to this pin
IRledPin_1 = 'D3'; %emitter led attached to this pin


valvePin1 = 'D10';


LED_1 = 'D12'; %probe port 1
LED_2 = 'D13';



%% Set up
configurePin(sensorArduino,IRledPin_1,'DigitalOutput');
configurePin(sensorArduino,IRdetectorPin_1,'DigitalInput');
configurePin(sensorArduino,IRdetectorPin_1, 'Pullup');
configurePin(sensorArduino,valvePin1,'DigitalOutput');

configurePin(sensorArduino,LED_1,'DigitalOutput');
configurePin(sensorArduino,LED_2,'DigitalOutput');


writeDigitalPin(sensorArduino,IRledPin_1, 1);
writeDigitalPin(sensorArduino,LED_1, 0);
writeDigitalPin(sensorArduino,LED_2, 0);
writeDigitalPin(sensorArduino,valvePin1, 0);

%% Experimental variables

finish=false;
stimulus1 = 0;
nosePoke1 = 0;



lastDebounceTime = 0;  %the last time the output pin was toggled
debounceDelay = 50;    %the debounce time; increase if the output flickers
priorState1 = 0;



log.logStimuliElapsedTimes.stimulus_1 = 0;



counter_1 = 0;

totalTime1 = 0;


%% Run experiment
folderName = uigetdir;
fileName = inputdlg('Enter experiment name:');
readygo = questdlg('Start experiment?', 'Start Acquisition', ...
    'Cancel', 'Start', 'Start');

%
if strcmp(readygo, 'Start')
    FS = stoploop('Stop Acquisition');
    log.startTime = clock;
    t00 = tic;
    origine = round(toc(t00)*1000);
    writeDigitalPin(sensorArduino,LED_2, 1);
    
    t01 = tic;
    j = 0;
%     log = [];
    log.onsetRecording = origine;
    while ~finish
        
        %         writeDigitalPin(sensorArduino,LED_1, 1);
        %         writeDigitalPin(sensorArduino,LED_2, 0);
        %         pause(1);
        %         writeDigitalPin(sensorArduino,LED_1, 0);
        %         writeDigitalPin(sensorArduino,LED_2, 1);
        %         pause(1);
        writeDigitalPin(sensorArduino,valvePin1, 1);
%         pause(100)
        
        
        
        
        elapsedTime1 = round(toc(t01)*1000);
        if elapsedTime1 > debounceDelay
            if (readDigitalPin(sensorArduino, IRdetectorPin_1) == 0)
                if priorState1 == 1
                    counter_1 = counter_1 + 1;
                    elapsedTime1 = round(toc(t1)*1000)
                    log.logStimuliElapsedTimes.stimulus_1(counter_1) = elapsedTime1;
                    totalTime1 = totalTime1 + elapsedTime1;
                    writeDigitalPin(sensorArduino,LED_1, 0);
                    priorState1 = 0;
                end
                t01 = tic;
            else
                if priorState1 == 0
                    nosePoke1 = nosePoke1 + 1
                    inizio1 = round(toc(t00)*1000);
                    writeDigitalPin(sensorArduino,LED_1, 1);
                    priorState1 = 1;
                    t1 = tic;
                    log.onsets.stimulus1(nosePoke1) = inizio1;
                    
                end
                t01 = tic;
            end
        end
        
        if FS.Stop()
            if priorState1 == 1
                    counter_1 = counter_1 + 1;
                    elapsedTime1 = round(toc(t1)*1000)
                    log.logStimuliElapsedTimes.stimulus_1(counter_1) = elapsedTime1;
                    totalTime1 = totalTime1 + elapsedTime1;
                    writeDigitalPin(sensorArduino,LED_1, 0);
                    priorState1 = 0;
            end
            break
        end
        
    end
    FS.Clear();
end
writeDigitalPin(sensorArduino,valvePin1, 0);
writeDigitalPin(sensorArduino,LED_1, 0);
writeDigitalPin(sensorArduino,LED_2, 0);

log.endRecording = round(toc(t00)*1000);

log.endTime = clock;
log.numberOfPokes.stimulus1 = nosePoke1;

log.totalInvestigationTime.stimulus1 = totalTime1;


log.InvestigationTimePerPoke.stimulus1.mean = mean(log.logStimuliElapsedTimes.stimulus_1); 
log.InvestigationTimePerPoke.stimulus1.std = std(log.logStimuliElapsedTimes.stimulus_1);


stringa1 = sprintf('Number of nose-pokes: %d', nosePoke1);
disp(stringa1);

stringa1_ = sprintf('Total Investigating Time: %d ms', totalTime1);
disp(stringa1_);




inizio = log.onsetRecording;
fine = log.endRecording;
timeline = zeros(1,(fine-inizio)+1);
for idxPokes = 1:nosePoke1
    iniziato = log.onsets.stimulus1(idxPokes);
    durato = log.logStimuliElapsedTimes.stimulus_1(idxPokes);
    timeline(iniziato:iniziato+durato) = 1;
end


log.timeline = timeline;


% fileName = ['Experiment_Log.mat'];
fileToSave = fullfile(folderName, fileName{1});
save(fileToSave, 'log')


%%
figure;
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gcf,'Position',[63 70 1266 726]);
subplot(2,3,[1 3])
plot(0:length(log.timeline)-1, log.timeline, 'r', 'linewidth', 3)
ylim([-1.5 1.5])
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'arial', 'fontsize', 14)
set(gca,'YColor','w')
set(gca,'YTick',[])
set(gca,'YTickLabel',[])

xlabel('Time (ms)')
subplot(2,3,4)
bar([log.numberOfPokes.stimulus1])
set(gca, 'box', 'off', 'tickDir', 'out', 'XTick',[],'fontname', 'arial', 'fontsize', 14)
ylabel('Number Of Nose Pokes')
xlabel(stringa1)
subplot(2,3,5)
bar([log.totalInvestigationTime.stimulus1])
set(gca, 'box', 'off', 'tickDir', 'out', 'XTick',[], 'fontname', 'arial', 'fontsize', 14)
ylabel('Time Spent Per Odor (ms)')
xlabel(stringa1_)
subplot(2,3,6)
if log.numberOfPokes.stimulus1 < 1
    x = 1;
else
    x = ones(log.numberOfPokes.stimulus1,1);
end
scatter(x, log.logStimuliElapsedTimes.stimulus_1)
xlim([0 2])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 14)

ylabel('Investigation Time Per Poke (ms)')

%%
clear a
