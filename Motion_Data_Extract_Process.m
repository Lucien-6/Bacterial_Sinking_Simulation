%% --------------Motion Data Extract & Process--------------- %%
%{
This program is used for batch extraction and processing of motion data obtained from 
the 'Bacterial Motion Stokes Simulation' project, ultimately obtaining chart information 
such as instantaneous velocity, settling velocity, MSD, diffusion coefficient, etc.

#Creator: Lucien            #Creation time: Nov. 15, 2024
#Modified by: Lucien     #Last modified time: 2026-08-18
#Version: 1.1.1

#Modify records:
1. Added average instantaneous velocity and fractal dimension analysis functions.
2. Added legend to MSD curve figure and saved workspace data.
3. Two trajectory characterization indicators, namely the maximum offset
rate and the final offset rate, have been added.
4. Added verification steps for case parameter settings.
5. Added trajectory example drawing and output function.
6. Added the function to calculate and plot the offset ratio-time curve.
7. Added the function of plotting the distribution of final landing points.
8. Smoothing optimized for mean offset ratio data.
9. Replace the offset ratio with a better offset angle.
10. Added batch processing function for cases.
11. Fixed an algorithmic error in the mean offset angle and introduced the
concept of mean offset coefficient.
12. 2026-07-31: folder picker for Cases; robust Case_Name via fileparts;
    require slanCL Add-On; skip FD figure when estimate is NaN.
13. 2026-08-18 (V1.1.1): slanCL palettes vendored under MATLAB Add-On/2000 palettes.

%}

%% Clear the cache

close all force
clear
clc

Start1 = tic; %The global timer is on.

%% List of cases to be processed
% Select either one case folder (contains CaseName_XX.mat) or a parent of case folders.

fprintf('Select a case results folder or a parent directory of case folders...\n');
parent_dir = uigetdir(pwd, 'Select Case Folder or Parent of Cases');
if parent_dir == 0
    error('No directory selected. Process terminated.');
end

[~, selected_name] = fileparts(parent_dir);
legacy_mats = dir(fullfile(parent_dir, [selected_name, '_*.mat']));
if ~isempty(legacy_mats)
    Cases = {parent_dir};
    fprintf('Detected a single case folder:\n  1. %s\n\n', parent_dir);
else
    dir_info = dir(parent_dir);
    dir_names = {dir_info([dir_info.isdir]).name};
    dir_names = dir_names(~ismember(dir_names, {'.', '..'}));
    if isempty(dir_names)
        error(['No case folders found in: %s\n', ...
            'Expected either legacy <CaseName>_N.mat files, or subfolders per case.'], parent_dir);
    end
    Cases = fullfile(parent_dir, dir_names);
    if ischar(Cases)
        Cases = {Cases};
    end
    fprintf('Found %d case(s) to process:\n', numel(Cases));
    for ii = 1:numel(Cases)
        fprintf('  %d. %s\n', ii, Cases{ii});
    end
    fprintf('\n');
end

for j = 1:length(Cases)
    %% Case Naming and Output Path Selection

    [~, Case_Name] = fileparts(Cases{j});
    disp([Case_Name,' starts processing!',newline])
    Output_Path = './Post-Processing'; %For terminal
    mkdir(Output_Path,Case_Name)

    %% Related parameter settings

    regexPattern = [Case_Name,'_\d+\.mat'];
    VarName = {'Pos','VM','major_axis','minor_axis','G'};%,'Pili_Matrix'};
    Tlim = [20,100];

    %Checking parameters
    MajA = 1.25e-6;
    MinA = 0.4e-6;
    Gravity = 9.81;
    % PM = [1;5;0;0;NaN;NaN;NaN;1];

    %% Batch extraction of motion related data
    FolderPath = Cases{j};
    Motion =  Extract_Var_from_Files(regexPattern,VarName,FolderPath);

    %% Post process the extracted data

    Num_Res = length(Motion.(VarName{2}));
    Sinking_Velocity = zeros(Num_Res,1);
    Mean_Velocity = zeros(Num_Res,1);
    Fractal_Dimension = zeros(Num_Res,1);
    Max_Offset_Ratio = zeros(Num_Res,1);
    Final_Offset_Ratio = zeros(Num_Res,1);
    Trajectories = cell(Num_Res,1);
    Final_YZ = zeros(Num_Res,2);

    for n = 1:Num_Res
        Res_Num = sprintf('%02d', n);%Output file number
        disp(['No.',Res_Num,' simulation result being processed ......',newline])
        %Parametric test
        if Motion.(VarName{3}){n} == MajA && Motion.(VarName{4}){n} == MinA && ...
                Motion.(VarName{5}){n} == Gravity %&& isequaln(Motion.(VarName{6}){n},PM)
            Temp = Motion.(VarName{2}){n};
            if n==1
                Times = Temp(:,7);
                MSD = zeros(length(Times),Num_Res);
                OA = zeros(length(Times),4);
            end
            MSD(:,n) = Temp(:,8);
            Sinking_Velocity(n) = Temp(end,6);
            Mean_Velocity(n) = mean(Temp(:,5));
            Trajectory = Motion.(VarName{1}){n}(1:3,:).*1e6;
            Final_YZ(n,:) = Trajectory(2:3,end);%Final landing point
            Pos(:,1) = [0;Times];
            Pos(:,2:4) = Trajectory';
            OA = OA+Offset_Ratio(Pos);%Offset ratio
            Trajectories{n} = Trajectory;
            Max_Offset_Ratio(n) = max(vecnorm(Trajectory(2:3,:)))/abs(Trajectory(1,end));
            Final_Offset_Ratio(n) = vecnorm(Trajectory(2:3,end))/abs(Trajectory(1,end));
            Fractal_Dimension(n) = Calculate_Fractal_Dimension(Trajectory',10);
            if ~isnan(Fractal_Dimension(n)) && ~isempty(get(0, 'CurrentFigure'))
                saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_',Res_Num,'_FD'],'png')%Save this figure
            end
        else
            error('The parameter settings for this case are incorrect !')
        end
        close all
    end

    Mean_MSD = mean(MSD,2);
    RDC = diff(Mean_MSD)/(6*(Times(2)-Times(1)));%Running diffusion curve
    MOA = OA./Num_Res;
    MOA(:,2) = atan(MOA(:,3)./MOA(:,4));%Mean offset angle 

    %% Draw corresponding result charts

    Simple = 5;
    assert(exist('slanCL', 'file') == 2, ...
        ['slanCL not found on the MATLAB path. Install the MATLAB Add-On ', ...
         '"2000 palettes" (slanCL), then re-run this script.']);
    Clist = slanCL(821);
    Tags = randi([1 Num_Res],Simple,1);

    figure('Name','Trajectories')
    set(gcf,'Position',[20 20 750 1000])
    for m = 1:Simple
        Trajectory = Trajectories{m};
        plot3(Trajectory(3,:),Trajectory(2,:),Trajectory(1,:),'LineWidth',1.5,'Color',Clist(m,:))
        hold on
    end
    set(gca,'ZDir','reverse','FontName','Times New Roman')
    grid on
    axis equal
    ax = gca; ax.LineWidth = 1.5;
    ax.FontSize = 12;
    title('Trajectories examples','FontSize',24,'FontWeight','bold')
    xlabel('Z / μm','FontSize',18);ylabel('Y / μm','FontSize',18);zlabel('X / μm','FontSize',18)
    hold off
    saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_Trajectories'],'png')%Save this figure

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

    figure('Name','Offset Angle Curve')
    set(gcf,'Position',[20 20 1200 1000])
    P1 = plot(MOA(:,1),MOA(:,2),'b','LineWidth',2.0);
    set(gca,'FontName','Times New Roman')
    grid on
    ax = gca; ax.LineWidth = 1.5;
    ax.FontSize = 12;
    title('Offset Angle Curve','FontSize',24,'FontWeight','bold')
    xlabel('Δt (s)','FontSize',18);ylabel('Offset Angle (rad)','FontSize',18);
    hold on
    %Fit the curve
    CutPoint = ceil(length(MOA(:,1))/3);
    Func = @(C,X) atan(C./sqrt(X));
    C = nlinfit(MOA(1:CutPoint,1),MOA(1:CutPoint,2),Func,1);
    P2 = plot(MOA(:,1),Func(C,MOA(:,1)),'r--','LineWidth',1.5);
    legend([P1,P2],{'Original Curve','Fitted Curve'})
    latexf = ['$$\leftarrow y=\arctan(\frac{',num2str(C),'}{\sqrt{(x)}})$$'];
    text(MOA(ceil(CutPoint/2),1),Func(C,MOA(ceil(CutPoint/2),1)),latexf,'Interpreter','latex','FontSize',18)
    saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_MOA'],'png')%Save this figure

    figure('Name','Final landing points')
    set(gcf,'Position',[20 20 1000 1000])
    L2 = scatter(Final_YZ(:,1),Final_YZ(:,2),40,'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5);
    hold on
    L = axis;
    plot([L(1), L(2)], [0, 0], 'k--','LineWidth',2.0);
    hold on
    plot([0, 0], [L(3), L(4)], 'k--','LineWidth',2.0);
    hold on
    L4 = plot(sum(Final_YZ(:,1))/50,sum(Final_YZ(:,2))/50,'rp','MarkerSize',15,'MarkerFaceColor','r');
    set(gca,'FontName','Times New Roman')
    axis equal
    grid on
    ax = gca; ax.LineWidth = 1.5;
    ax.FontSize = 12;
    title('Final Landing Points','FontSize',24,'FontWeight','bold')
    xlabel('Y (μm)','FontSize',18);ylabel('Z (μm)','FontSize',18);
    legend([L2,L4],{'Final landig points','Mean landing point'},'FontSize',16,'Location','northeast')
    saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_FLP'],'png')%Save this figure

    %% Post processing completed, reporting time

    MPD = struct('Sinking_Velocity',Sinking_Velocity,'Mean_Velocity',Mean_Velocity, ...
        'Max_Offset_Ratio',Max_Offset_Ratio,'Final_Offset_Ratio',Final_Offset_Ratio, ...
        'Fractal_Dimension',Fractal_Dimension,'Mean_Offset_Angle',MOA,'Diffusion_Coefficient', ...
        fo.p2/6,'Fitted_Sinking_Velocity',sqrt(fo.p1),'Mean_Offset_Coefficient',C);
    % MPD = struct('Sinking_Velocity',Sinking_Velocity,'Mean_Velocity',Mean_Velocity, ...
    %     'Fractal_Dimension',Fractal_Dimension,'Diffusion_Coefficient',fo.p1/6, ...
    %     'Mean_Offset_Angle',MOA,'Mean_Offset_Coefficient',C);
    save([Output_Path,'/',Case_Name,'/',Case_Name,'_Motion Post-Data.mat'],'MPD')

    save([Output_Path,'/',Case_Name,'/',Case_Name,'.mat']); %Save all data in the workspace
    close all
    disp([Case_Name,' has been processed!',newline])

end

Run_Time = toc(Start1);
fprintf('#All cases post-processed in %.2f seconds.\n',Run_Time)