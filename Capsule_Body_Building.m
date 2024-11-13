function [Capsule_str,Nhead] = Capsule_Body_Building(Nhead,minor_axis,major_axis,shift)
% Capsule_Body_Building This program is used to construct bacterial body models (capsule type)
% e.g. [Capsule_str,Nhead] = Capsule_Body_Building(NCapsule,minor_axis,major_axis,shift)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-24

SA = 4*pi*minor_axis^2;
CA = 4*pi*minor_axis*(major_axis-minor_axis);
SPN = round(Nhead*SA/(SA+CA));
CPN = Nhead-SPN;

%Uniform distribution of points on a spherical surface
SLoc = zeros(SPN, 3);
for ii = 1 : SPN
    phi = acos(-1.0 + (2.0 * ii - 1.0) / SPN);
    theta = sqrt(SPN * pi) * phi;
    % theta = 2*pi*ii*(sqrt(5)-1)/2; %Fibonacci Lattice
    SLoc(ii, 3) = minor_axis * cos(theta) * sin(phi);
    SLoc(ii, 2) = minor_axis * sin(theta) * sin(phi);
    SLoc(ii, 1) = minor_axis * cos(phi);
end
DM = pdist2(SLoc,SLoc);
DM(DM==0) = NaN;
MDA = min(DM,[],'omitmissing');
SDis = mean(MDA);

if CPN > 0
    %Uniform distribution of points on a cylindrical surface
    CDis = sqrt(CA/CPN);
    Turns = ceil(2*(major_axis-minor_axis)/CDis);
    CDis = 2*(major_axis-minor_axis)/Turns;
    TN = ceil(CPN/Turns);
    Alpha = 0:2*pi/TN:(2*pi-2*pi/TN);
    TempX = (minor_axis-major_axis+CDis/2):CDis:(major_axis-minor_axis-CDis/2);
    TempY = minor_axis*sin(Alpha);
    TempZ = minor_axis*cos(Alpha);
    CLoc = zeros(TN*Turns,3);
    CLoc(:,1) = repelem(TempX,TN);
    CLoc(:,2) = repmat(TempY',Turns,1);
    CLoc(:,3) = repmat(TempZ',Turns,1);
else
    CDis = NaN;
    CLoc = NaN(3,3);
    Turns = 0;
    TN = 0;
end

%Calculation of the rate of deflection of the point of force action
MDis = mean([SDis,CDis],'omitmissing');
FDis = MDis*shift;
Ratio = (minor_axis-FDis)/minor_axis;

%Arrange the force points
SGLoc = Ratio*SLoc;
CGLoc = [CLoc(:,1),CLoc(:,2:3)*Ratio];

%Assembling Cylinder and Sphere
SLoc(SLoc(:,1)<=0,1) = SLoc(SLoc(:,1)<=0,1)-major_axis+minor_axis;
SLoc(SLoc(:,1)>0,1) = SLoc(SLoc(:,1)>0,1)+major_axis-minor_axis;
SGLoc(SGLoc(:,1)<=0,1) = SGLoc(SGLoc(:,1)<=0,1)-major_axis+minor_axis;
SGLoc(SGLoc(:,1)>0,1) = SGLoc(SGLoc(:,1)>0,1)+major_axis-minor_axis;

rxS = [SLoc(SLoc(:,1)<=0,1);CLoc(:,1); SLoc(SLoc(:,1)>0,1)];
ryS = [SLoc(SLoc(:,1)<=0,2);CLoc(:,2); SLoc(SLoc(:,1)>0,2)];
rzS = [SLoc(SLoc(:,1)<=0,3);CLoc(:,3); SLoc(SLoc(:,1)>0,3)];

gxS = [SGLoc(SGLoc(:,1)<=0,1);CGLoc(:,1); SGLoc(SGLoc(:,1)>0,1)];
gyS = [SGLoc(SGLoc(:,1)<=0,2);CGLoc(:,2); SGLoc(SGLoc(:,1)>0,2)];
gzS = [SGLoc(SGLoc(:,1)<=0,3);CGLoc(:,3); SGLoc(SGLoc(:,1)>0,3)];

rxS(isnan(rxS)) = [];
ryS(isnan(ryS)) = [];
rzS(isnan(rzS)) = [];

gxS(isnan(gxS)) = [];
gyS(isnan(gyS)) = [];
gzS(isnan(gzS)) = [];

Nhead = SPN+Turns*TN;

% %Drawing the final modeling image
% figure('Name','Images of bacterial body model')
% set(gcf,'unit','centimeters','position',[15,15,25,20]);
% plot3(rxS,ryS,rzS,'.B',gxS,gyS,gzS,'.r');
% title('3D Schematic of Bacterial Body Model');
% xlabel('X');ylabel('Y');zlabel('Z');
% legend('Location points','Force points');
% axis equal;

Capsule_str = struct('rxS',rxS,'ryS',ryS,'rzS',rzS,'gxS',gxS,'gyS',gyS,'gzS',gzS);

end
