%% Single session analysis 

clear all 

% Select the response window
responseWindow = [10 11];       % consider the LED window
%responseWindow= [7 11];         % consider the whole window after stimulus

% Select mouse and session 
% Index        1       2       3      4       5       6      7      8     9
mouse_list= ["PV92" "PV94" "PV100" "PV104" "PV107" "WT58" "WT96" "WT97" "WT98" "WT101"];

%%%%%%% CHANGE THESE PARAMETERS %%%%%%%
mouse_name = mouse_list(9);   
session_number= 1;            
filename= mouse_name+'_day'+num2str(session_number);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load data
filepath= "C:\Users\ricca\Documents\Iurilli Lab\Experiments\Optoinhibition\optoinhibition\exp\pavlovian\"+mouse_name;
toolpath= "C:\Users\ricca\Documents\MATLAB\Learning Analysis\IndividualAnalysisEM"; 
cd(filepath);
filesList = dir('*.mat');
load(filesList(1).name)

% Run analysis
I = zeros(1, size(SessionData.TrialTypes,2));
for idxTrial = 1:size(SessionData.TrialTypes,2)
    trialType = SessionData.TrialTypes(idxTrial);
    if isfield(SessionData.RawEvents.Trial{1,idxTrial}.Events, 'Port1In')
        responses = SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In(SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In > responseWindow(1)...
            &  SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In < responseWindow(2));
        switch trialType
            case 1
                if isempty(responses)
                    I(idxTrial) = 1;
                else
                    I(idxTrial) = 0;
                end
            case 2
                if isempty(responses)
                    I(idxTrial) = 0;
                else
                    I(idxTrial) = 1;
                end
        end
    else
        switch trialType
            case 1
                I(idxTrial) = 1;
            case 2
                I(idxTrial) = 0;
        end
    end
    
end
cd(toolpath);
runanalysis(I,1, 0.5, 0.005, 2)
plotresults_1

% Reload data to save them in the right dir
data= load("resultsindividual.mat");
cd("C:\Users\ricca\Documents\Iurilli Lab\Experiments\Optoinhibition\optoinhibition\exp\pavlovian\learning analysis results");
save(filename, "data") 

%% Multiple sessions analysis
clear all 
% Select the response window
responseWindow = [10 11];       % consider the LED window
%responseWindow= [7 11];         % consider the whole window after stimulus

% Select the mouse 
% Index        1       2       3      4       5       6      7      8     9
mouse_list= ["PV92" "PV94" "PV100" "PV104" "PV107" "WT58" "WT96" "WT97" "WT98" "WT101"];
%%%%%%% CHANGE THESE PARAMETERS %%%%%%%
mouse_name = mouse_list(2);           
filename= mouse_name + "_alldays";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load data 
filepath= "C:\Users\ricca\Documents\Iurilli Lab\Experiments\Optoinhibition\optoinhibition\exp\pavlovian\"+mouse_name;
toolpath= "C:\Users\ricca\Documents\MATLAB\Learning Analysis\IndividualAnalysisEM"; 
cd(filepath);
filesList = dir('*.mat');

% Run analysis
allTrials= [];
for file = 1:length(filesList)
    load(filesList(file).name);
    I = zeros(1, size(SessionData.TrialTypes,2));
    for idxTrial = 1:size(SessionData.TrialTypes,2)
        trialType = SessionData.TrialTypes(idxTrial);
        if isfield(SessionData.RawEvents.Trial{1,idxTrial}.Events, 'Port1In')
            responses = SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In(SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In > responseWindow(1)...
                &  SessionData.RawEvents.Trial{1,idxTrial}.Events.Port1In < responseWindow(2));
            switch trialType
                case 1
                    if isempty(responses)
                        I(idxTrial) = 1;
                    else
                        I(idxTrial) = 0;
                    end
                case 2
                    if isempty(responses)
                        I(idxTrial) = 0;
                    else
                        I(idxTrial) = 1;
                    end
            end
        else
            switch trialType
                case 1
                    I(idxTrial) = 1;
                case 2
                    I(idxTrial) = 0;
            end
        end
    end
    allTrials= [allTrials I];
end
cd(toolpath);
runanalysis(allTrials,1, 0.5, 0.005, 2)
plotresults_1

% Reload data to save them in the right dir
data= load("resultsindividual.mat");
cd("C:\Users\ricca\Documents\Iurilli Lab\Experiments\Optoinhibition\optoinhibition\exp\pavlovian\learning analysis results");
save(filename, "data") 