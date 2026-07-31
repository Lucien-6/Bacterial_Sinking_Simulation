%% ---------------------Bacteria Motion Stokes Simulation V1.1 ----------------------- %%
%{
This program uses the Stokes method to numerically simulate the motion of
bacteria in liquids, the relevant variables are all in international basic units or 
their derived units. This program was created based on the modification of
the original program by Prof. Yang Ding of the Beijing Computational Science
Research Center.

#Creator: Lucien            #Creation time: Oct. 10, 2024
#Modified by: Lucien       #Last modified time: 2026-07-31
#Version: 1.1.0

#Modify records:
----------------------------- V1.1.0 (2026-07-31) --------------------------
1. Zero-angle quaternion guard in Sink_Force_Update.
2. True no-pili via Pili_Matrix = zeros(8,0); safe skip of invalid columns.
3. Time loop mobility solve uses FM\F; clear dense Green factors after FM.
4. Green-matrix condest warning; Force_Log stores applied generalized load.
5. Animation optional (MPEG-4); document unused bodyU/U_tail/T_tail.

----------------------------- V1.0 --------------------------
1. Bacterial velocity and MSD calculation analysis added.
2. Set the mean of random force to 0 through translation.
3. Added MSD curve fitting analysis function.
4. Added friction matrix decoupling function.
5. Convert coordinate system using quaternions.
6. Added random number seed that follows time.
7. Optimized MSD curve fitting algorithm.
8. Added progress display during coordinate system conversion.
9. Optimized the content of the waitbar display.
10. Improved calculation of relaxation time.

%}

%% Clear the cache

close all force
clear
clc

Start1 = tic; %The global timer is on.

%% Case Naming and Output Path Selection

Case_Name = 'Test';
% Output_Path = uigetdir('./','Please select the path to save the results ...'); %For GUI
Output_Path = './Results'; %For terminal
mkdir(Output_Path,Case_Name)

%% The program starts and turns on logging

diary([Output_Path,'/',Case_Name,'/',Case_Name,'.log']) %Turn on logging
disp(['【Case Name】: ',Case_Name])
disp('////////////////////////////////////////Simulation Begain\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\')
fprintf('@The program start time is: %s \n\n',string(datetime));

%% Liquid environment, bacterial body and pili parameter setting

%Parameters of liquid（water at 30℃）
Temper = 303.15; %Kelvin temperature
KB = 1.380649e-23; %Boltzmann constant
Density_F = 995.676; %Density
G = 9.81; %Gravitational acceleration
Miu = 0.0008007; %Coefficient of dynamic viscosity

%Parameters of bacterial body (Capsule type)
major_axis = 1.25e-6; %Major axis length
minor_axis = 0.4e-6; %minor axis length
Nhead = 1000; %Number of points
shift = 1.25; %Force point offset rate
Density_B = 1180.0; %Bacterial mass density
Volume_B = pi*minor_axis^2*(4/3*minor_axis+2*(major_axis-minor_axis)); %Bacterial volume

%Parameters of pilis
%{
Pili Matrix: A matrix of pili properties.
The first row indicates the morphology, with the following values:
1=linear, 2=parabolic, 3=circular, 4=expansive sinusoidal, 5=conical spiral.
The second row shows the length in micrometres. 
The third row displays the angle of deflection with respect to the Z-axis. 
The fourth row presents the deflection angle relative to the X-axis. 
The fifth, sixth and seventh rows represent the parameters of the
morphology control. In the case of the linear type, no additional parameter
is required, so the value is set to nan. The parameter for the parabolic
type is the coefficient k, while the parameter for the arc type is the
angle of the centre of the circle. The sinusoidal type has two parameters,
namely the dilatation coefficient and the periodicity coefficient. In
contrast, the solenoidal type has three parameters: the planar dilatation
coefficient, the vertical dilatation coefficient and the periodicity coefficient.
The eighth row represents the configuration of the pili on the bacterial
body, with a total of 1–14 points (see the point schematic for further details).
Use Pili_Matrix = zeros(8,0) for a true no-pili configuration.
%}
Pili_Matrix = zeros(8, 0); % True no-pili body (B1)

ppp = 100; %Number of points per micron
dis = 5e-8; %Distance between the body and the root of pili (must be greater than 0)
epsA=0.003e-6; %Regularization parameter of the smooth function (approximating the physical radius of the pili)

%Other property
Sink_Force = (Density_B-Density_F)*G*Volume_B; %Sinking force on bacteria

%% Time setting

TStep = 0.01; %Time step size
TEnd = 10; %Length of time
TNum = round(TEnd/TStep+1); %Total time step counts

%% Bacteria and pili autonomous movement parameter setting
% NOTE (this flat V1.1 build): bodyU / U_tail / T_tail are NOT used by the
% solver. Changing them has no effect. Active swimming / pili extension will
% require merging the Contract-branch dynamics modules.

bodyU = [0.0 0.0 0.0 0.0 0.0 0.0]; %#ok<NASGU> % unused in this build
U_tail = [0.0 0.0].*1e-6; %#ok<NASGU> % unused in this build
T_tail = [20 20]; %#ok<NASGU> % unused in this build

%% Bacteria initial posture and gravity direction setting

Sink_Theta = [0,0,0*pi/2]; %Bacteria initial posture
Force_Direct = [1;0;0].*Sink_Force; %Sinking force vectors in Eulerian coordinate system

%% Bacterial modeling

disp([newline,'Starting to build the bacterial model ……'])

[bHead,Nhead] = Capsule_Body_Building(Nhead,minor_axis,major_axis,shift); %Body modeling
pili = Pilis_Modelling(Pili_Matrix,ppp,major_axis,minor_axis,dis); %Pili modeling
bac  = Assemble_Body_Pilis(Nhead,bHead,pili,major_axis); %Assembling the body and pili

disp([newline,'The bacterial model has been built !'])

%% Calculate the friction coefficient matrix

disp([newline,'Calculating the friction coefficient matrix ……'])

NALL = bac.NBac; %Total number of points

%Construct the original Green's function matrix
Mall = Original_Green_Function_Matrix(bac,Nhead,NALL,epsA,Miu);

%Expand Green's function matrix
M = Expanded_Green_Function_Matrix(NALL,Nhead,bac,major_axis,Mall);

cM = condest(M);
if cM > 1e16
    warning('Green matrix ill-conditioned: condest(M)=%.3e. Check Nhead/shift/epsA.', cM);
end

% Optimization for the expand Green's function matrix for subsequent convergence of the solution
[P,R,C] = equilibrate(M);
B = R*P*M*C;
BB = B\eye(3*NALL+6,3*NALL+6);

U = zeros(3*NALL+6,1); %Expand velocity vector

EFT = eye(6,6);
Temp_FM = zeros(6,6);

for n = 1:6
    %Given a known external force or torque
    U(3*NALL+1:3*NALL+6) = EFT(n,:);
    UU = R*P*U; %The corresponding transformations for U
    Temp_Force = BB*UU; %Solving systems of equations
    Force = C*Temp_Force; %Inverse back to the actual Force vector
    Temp_FM(:,n) = Force(3*NALL+1:3*NALL+6); %Calculating the coefficient of friction
end
FM = Temp_FM\eye(6,6); %Friction matrix

%Decoupling the friction matrix
DFM = Decouping_Friction_Matrix(FM);

% Large dense factors are no longer needed in the time loop (use FM\F)
clearvars Mall M B BB U UU Temp_Force Force Temp_FM EFT P R C

disp([newline,'The friction coefficient matrix is calculated !'])

%% Construct Brownian motion stochastic forces

rng('shuffle') %Random seed changs with time

Rand = randn(TNum,6);

Rand = Rand-mean(Rand); %Set the mean to 0 through translation

Brown = sqrt(2*KB*Temper*diag(DFM)./TStep);

disp([newline,'Brownian motion stochastic force constructed !'])

%% Formally enter the simulation iterative computation

Step_Times = zeros(TNum,1); %Array of time-per-step records

Trans = cell(2,TNum); %Coordinate system rotation matrix

Velocity_Log = zeros(6,TNum); %Velocity records
Force_Log = zeros(6,TNum); %Applied generalized force/torque records

PR = cell(1,TNum); %Pili morphology recording cell

Bar = waitbar(0,'1','Name','BMSS_V1.1 Running',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
set(Bar,"Position",[500 500 275 100])
setappdata(Bar,'canceling',0); %Waitbar setting

hour = nan;
minute = nan;
second = nan;

disp([newline,'Formally enter the simulation iterative computation !'])

for i = 1:TNum

    Start2 = tic;

    %Get the state of the “Cancel” button and make a judgment
    if getappdata(Bar,'canceling')
        warning('Calculations have been aborted by the user!')
        break
    end
    %Update the waitbar
    str = ['Case Name: ',Case_Name,newline,' Step ',num2str(i),' / ',num2str(TNum),' is being calculated now ……', ...
        newline,'ETA: ',num2str(hour),' h ',num2str(minute),' m ',num2str(second),' s'];
    newStr = strrep(str, '_', '-');
    waitbar(i/TNum,Bar,newStr)

    %Update the sinking force at step i in Lagrangian coordinates
    [Q,US] = Sink_Force_Update(i,Sink_Theta,TStep,Velocity_Log,Force_Direct);

    if i == 1
        Trans{1,i} = Q;
        Trans{2,i} = conj(Q);
    else
        Trans{1,i} = Trans{1,i-1}*Q;
        Trans{2,i} = conj(Q)*Trans{2,i-1};
    end

    Force_Direct = US;

    %Model checking
    % Model_Checking(bac)

    % Applied generalized force/torque (gravity + Brownian) and mobility solve
    F = zeros(6, 1);
    F(1:3) = Force_Direct' + Rand(i, 1:3) .* Brown(1:3)';
    F(4:6) = Rand(i, 4:6) .* Brown(4:6)';
    Force_Log(:, i) = F;
    Velocity_Log(:, i) = FM \ F;

    fprintf(['--------------------------------------------------------------\n' ...
        '#Step %d Iterative computation completed ! \n'],i)

    %Record the relative position of pili and morphological data for the step
    PR{i} = [bac.rxT;bac.ryT;bac.rzT];

    % Report the time spent on this step and the estimated time remaining
    Step_Times(i) = toc(Start2);
    fprintf('$This step took time：%6.2f s ! \n',Step_Times(i));
    ReT = mean(Step_Times(1:i))*(TNum-i);
    [hour,minute,second] = s2hms(ReT);

end

delete(Bar); %Solution complete, close the waitbar

disp([newline,'Simulation iteration complete !'])

%% Calculating and plotting the trajectory of the bacteria in the Eulerian coordinate system

disp([newline,'Start calculating the trajectory of the bacterial motion in the Eulerian coordinate system ……'])
Pos = Calculate_Motion_Trajectory(TNum,major_axis,Velocity_Log,TStep,Trans,Case_Name,Output_Path);
disp([newline,'Bacterial trajectory is calculated !'])

%% Computing velocity of bacteria

disp([newline,'Calculate bacterial sinking velocity and MSD ……'])
Tlim = zeros(2,1);
Tlim(1) = ceil(max(diag(DFM(4:6,4:6))./(KB*Temper))); %Relaxation time
Tlim(2) = TEnd/2;
VM = Calculate_Velocity_MSD(Pos,TStep,Case_Name,Tlim,Output_Path);
disp([newline,'Bacterial sinking velocity and MSD is calculated !'])

%% Animating the motion of the bacteria in the Eulerian coordinate system
% Disabled by default (slow). Uncomment to generate MPEG-4 animation.

% disp([newline,'Animating bacterial motion ……'])
% Bacteria_Motion_Animations(Case_Name,TStep,major_axis,TNum,bac,PR,Trans,Velocity_Log,Pos,Output_Path);
% disp([newline,'Bacterial motion animation completed !'])

%% Completion of the program and statistical reporting

Time = toc(Start1);
clearvars Force_Direct hour minute bHead pili second US Bar newStr str F Q
save([Output_Path,'/',Case_Name,'/',Case_Name,'.mat']); %Save all data in the workspace
fprintf('\n@Total running time：%6.2f hours\n\n',Time/3600);
fprintf('@The moment the programme completion is: %s \n',string(datetime));
disp('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\Simulation End/////////////////////////////////////////')
% configinfo; %Get system configuration information
diary off %End of logging
