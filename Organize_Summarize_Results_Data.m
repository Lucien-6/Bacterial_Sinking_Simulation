%% --------------Organize & Summarize Results Data--------------- %%
%{
This program is used to organize and summarize the large amount of resultant data 
obtained from post-processing, and finally save the organized data as a clear, concise 
and easy-to-use excel file.

#Creator: Lucien            #Creation time: Dec. 15, 2024
#Modified by: Lucien       #Last modified time: 2026-08-18
#Version: 1.1.1

#Modify records:
1. Header synchronized with project V1.1.1 documentation set.

%}

%% Clear the cache

close all force
clear
clc

Start1 = tic; %The global timer is on.

%% Path and parameter settings

folderPath = uigetdir('', 'Select the folder containing your results data ...');
filePattern = '.*_Motion Post-Data\.mat$';
varName = 'MPD';
excelName = 'Final Data.xls';

%% Get the name of each case

items = dir(folderPath);
subFolders = items([items.isdir]);
subFolderNames = {subFolders(~ismember({subFolders.name}, {'.', '..'})).name};
caseNumber = length(subFolderNames);

%% Extract all data and get variable names

Data =  Extract_Var_from_Files(filePattern,varName,folderPath);
MPD = Data.MPD;
fieldNames = fieldnames(MPD{1});

%% Organize and summarize the data and finally write it to the excel file

for m = 1:length(fieldNames)
    for n = 1:caseNumber
        if strcmp(fieldNames{m},'Mean_Offset_Angle')
            subData = MPD{n}.(fieldNames{m})(:,2);
        else
            subData = MPD{n}.(fieldNames{m});
        end
        if n == 1
            Temp = zeros(length(subData),caseNumber);
        end
        Temp(:,n) = subData;
    end
    T = array2table(Temp,"VariableNames",subFolderNames);
    writetable(T,[folderPath,'\',excelName],"Sheet",fieldNames{m})
end

%% Post processing completed, reporting time

disp(['@All data has been written into the file named "',excelName, '" !']);
Run_Time = toc(Start1);
fprintf('#Program running time:  %.2f seconds.\n\n',Run_Time)
