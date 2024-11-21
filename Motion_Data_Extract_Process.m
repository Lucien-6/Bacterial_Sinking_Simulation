%% --------------Motion Data Extract & Process--------------- %%
%{
This program is used for batch extraction and processing of motion data obtained from 
the "Bacterial Motion Stokes Simulation" project, ultimately obtaining chart information 
such as instantaneous velocity, settling velocity, MSD, diffusion coefficient, etc.

#Creator: Lucien            #Creation time: Nov. 15, 2024
#Modified by: Lucien     #Last modified time: Nov. 20, 2024

#Modify records:
1. Added average instantaneous velocity and fractal dimension analysis functions.
2. Added legend to MSD curve figure and saved workspace data.
3. Two trajectory characterization indicators, namely the maximum offset
rate and the final offset rate, have been added.

%}

%% Clear the cache

close all force
clear
clc

Start1 = tic; %The global timer is on.

%% Case Naming and Output Path Selection

Case_Name = 'NoPili_A2_dt001_T300';
% Case_Name = 'Ball_R1_G0_dt001_T300';
% Output_Path = uigetdir('./','Please select the path to save the results ...'); %For GUI
Output_Path = './Post-Processing'; %For terminal
mkdir(Output_Path,Case_Name)

%% Related parameter settings

regexPattern = [Case_Name,'_\d{2}\.mat'];
VarName = {'Pos','VM'};
Tlim = [3,150];

%% Batch extraction of motion related data

Motion =  Extract_Var_from_Files(regexPattern,VarName);

%% Post process the extracted data

Num_Res = length(Motion.(VarName{2}));
Sinking_Velocity = zeros(Num_Res,1);
Mean_Velocity = zeros(Num_Res,1);
Fractal_Dimension = zeros(Num_Res,1);
Max_Offset_Ratio = zeros(Num_Res,1);
Final_Offset_Ratio = zeros(Num_Res,1);

for n = 1:Num_Res
    Res_Num = sprintf('%02d', n);%Output file number
    disp(['No.',Res_Num,' simulation result being processed ......',newline])
    Temp = Motion.(VarName{2}){n};
    if n==1
        Times = Temp(:,7);
        MSD = zeros(length(Times),Num_Res);
    end
    MSD(:,n) = Temp(:,8);
    Sinking_Velocity(n) = Temp(end,6);
    Mean_Velocity(n) = mean(Temp(:,5));
    Trajectory = Motion.(VarName{1}){n}(1:3,:).*1e6;
    Max_Offset_Ratio(n) = max(vecnorm(Trajectory(2:3,:)))/abs(Trajectory(1,end));
    Final_Offset_Ratio(n) = vecnorm(Trajectory(2:3,end))/abs(Trajectory(1,end));
    Fractal_Dimension(n) = Calculate_Fractal_Dimension(Trajectory',10);
    saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_',Res_Num,'_FD'],'png')%Save this figure
end

Mean_MSD = mean(MSD,2);
RDC = diff(Mean_MSD)/(6*(Times(2)-Times(1)));

%% Draw corresponding result charts

figure('Name','MSD Curves')
set(gcf,'Position',[20 20 1200 1000])
plot(Times,MSD,'LineWidth',1.5)
hold on
L1 = plot(Times,Mean_MSD,'--k','LineWidth',3.0);
set(gca,'FontName','Times New Roman')
grid on
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
title('MSD Curves','FontSize',24,'FontWeight','bold')
xlabel('Δt (s)','FontSize',18);ylabel('MSD (μm^2)','FontSize',18);
legend(L1,'Mean MSD','FontSize',16,'Location','northwest')
saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_MSD'],'png')%Save this figure

figure('Name','RDC Curves')
set(gcf,'Position',[20 20 1200 1000])
plot(Times(1:end-1),RDC,'r','LineWidth',2.0)
set(gca,'FontName','Times New Roman')
grid on
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
title('RDC Curve','FontSize',24,'FontWeight','bold')
xlabel('Δt (s)','FontSize',18);ylabel('RDC (μm^2/s)','FontSize',18);
saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_RDC'],'png')%Save this figure

figure('Name','Fitting MSD')
set(gcf,'Position',[20 20 1200 1000])
ExlcudeData = Times<Tlim(1) | Times>Tlim(2);
[fo,gof] = fit(Times,Mean_MSD,'poly2','Lower',[0 0 0],'Upper',[Inf Inf 0],'Exclude',ExlcudeData);
% [fo,gof] = fit(Times,Mean_MSD,'poly1','Lower',[0 0],'Upper',[Inf 0],'Exclude',ExlcudeData);
L3 = plot(fo,'--r',Times,Mean_MSD,'-b',ExlcudeData,'.b');
set(gca,'FontName','Times New Roman')
L3(1).LineWidth = 3.0;
L3(2).MarkerSize = 1.0;
grid on
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
title('Fitted curve of MSD','FontSize',24,'FontWeight','bold')
xlabel('Δt (s)','FontSize',18);ylabel('MSD (μm^2)','FontSize',18);
legend({'Simulation Data','Exlcude Data','Fitted Curve'},'FontSize',16,'Location','southeast')
latexf = ['$${\bf y}=6*',num2str(fo.p2/6),'*\Delta{\bf t}+',num2str(sqrt(fo.p1)),'^2*\Delta{\bf t}^2, ' ...
    'R^2=',num2str(gof.adjrsquare),' \rightarrow $$'];
% latexf = ['$${\bf y}=6*',num2str(fo.p1/6),'*\Delta{\bf t}, R^2=',num2str(gof.adjrsquare),' \rightarrow $$'];
text(Tlim(2),fo(Tlim(2)),latexf,'Interpreter','latex','FontSize',14,'Color','k','HorizontalAlignment','right')
saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_Fitted-MSD'],'png')%Save this figure

%% Post processing completed, reporting time

MPD = struct('Sinking_Velocity',Sinking_Velocity,'Mean_Velocity',Mean_Velocity, ...
    'Max_Offset_Ratio',Max_Offset_Ratio,'Final_Offset_Ratio',Final_Offset_Ratio, ...
    'Fractal_Dimension',Fractal_Dimension,'Diffusion_Coefficient',fo.p2/6,'FSV',sqrt(fo.p1));
% MPD = struct('Sinking_Velocity',Sinking_Velocity,'Mean_Velocity',Mean_Velocity, ...
%     'Fractal_Dimension',Fractal_Dimension,'Diffusion_Coefficient',fo.p1/6);
save([Output_Path,'/',Case_Name,'/',Case_Name,'_Motion Post-Data.mat'],'MPD')

save([Output_Path,'/',Case_Name,'/',Case_Name,'.mat']); %Save all data in the workspace

Run_Time = toc(Start1);
fprintf('All motion data post-processed in %.2f seconds.\n',Run_Time)