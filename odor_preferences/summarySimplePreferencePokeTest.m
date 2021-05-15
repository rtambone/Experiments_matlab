clc
clear
folderList = uipickfiles('FilterSpec', '/Volumes/Odor Preference Test/Odor Preference Test/wolfVSmouse/', 'Output', 'struct'); 

for idxMouse = 1:length(folderList)
    cd(folderList(idxMouse).name);
    load('Experiment_Log.mat');
    numberOfPokes(idxMouse,1) = log.numberOfPokes.stimulus1;
    numberOfPokes(idxMouse,2) = log.numberOfPokes.stimulus2;
    totalInvestigationTime(idxMouse,1) = log.totalInvestigationTime.stimulus1;
    totalInvestigationTime(idxMouse,2) = log.totalInvestigationTime.stimulus2;
    investigationTimePerPoke(idxMouse,1) = log.InvestigationTimePerPoke.stimulus1.mean;
    investigationTimePerPoke(idxMouse,2) = log.InvestigationTimePerPoke.stimulus2.mean;
    nPokesIndex(idxMouse) = (numberOfPokes(idxMouse,1) - numberOfPokes(idxMouse,2)) / (numberOfPokes(idxMouse,1) + numberOfPokes(idxMouse,2));
    totTimeIndex(idxMouse) = (totalInvestigationTime(idxMouse,1) - totalInvestigationTime(idxMouse,2)) / (totalInvestigationTime(idxMouse,1) + totalInvestigationTime(idxMouse,2));
    partTimeIndex(idxMouse) = (investigationTimePerPoke(idxMouse,1) - investigationTimePerPoke(idxMouse,2)) / (investigationTimePerPoke(idxMouse,1) + investigationTimePerPoke(idxMouse,2));
end




%%
figure;
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gcf,'Position',[63 70 1266 726]);




color = 'r';
subplot(2,3,1)
my_ttest2_boxplot(numberOfPokes(:,1), numberOfPokes(:,2), 'k', {'wolf urine', 'mouse urine'})
hold on
plot([4,5],mean(numberOfPokes),'-sr',...
       'MarkerFaceColor', color, 'color', color)
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Number Of Nose Pokes')
hold off

subplot(2,3,2)
my_ttest2_boxplot(totalInvestigationTime(:,1), totalInvestigationTime(:,2), 'k', {'wolf urine', 'mouse urine'})
hold on
plot([4,5],mean(totalInvestigationTime),'-sr',...
       'MarkerFaceColor', color, 'color', color)
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Investigation Time Per Odor (ms)')
hold off

subplot(2,3,3)
my_ttest2_boxplot(investigationTimePerPoke(:,1), investigationTimePerPoke(:,2), 'k', {'wolf urine', 'mouse urine'})
hold on
plot([4,5],mean(investigationTimePerPoke),'-sr',...
       'MarkerFaceColor', color, 'color', color)
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Investigation Time Per Poke (ms)')
hold off


subplot(2,3,4)
hold on
for idxMouse = 1:numel(nPokesIndex)
plot(2,nPokesIndex(idxMouse),'ok',...
       'MarkerFaceColor', 'k', 'color', 'k')
end
plot(2,mean(nPokesIndex),'sr',...
       'MarkerFaceColor', color, 'color', color)
xlim([1 3])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Number Of Nose Pokes Index')
hold off

subplot(2,3,5)
hold on
for idxMouse = 1:numel(totTimeIndex)
plot(2,totTimeIndex(idxMouse),'ok',...
       'MarkerFaceColor', 'k', 'color', 'k')
end
plot(2,mean(totTimeIndex),'sr',...
       'MarkerFaceColor', color, 'color', color)
xlim([1 3])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Total Investigation Time Index')
hold off

subplot(2,3,6)
hold on
for idxMouse = 1:numel(partTimeIndex)
plot(2,partTimeIndex(idxMouse),'ok',...
       'MarkerFaceColor', 'k', 'color', 'k')
end
plot(2,mean(partTimeIndex),'sr',...
       'MarkerFaceColor', color, 'color', color)
xlim([1 3])
set(gca, 'box', 'off', 'tickDir', 'out','fontname', 'arial', 'fontsize', 12)
ylabel('Investigation Time Per Poke Index')
hold off

