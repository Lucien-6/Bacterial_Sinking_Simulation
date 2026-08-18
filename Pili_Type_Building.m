function Pili_str = Pili_Type_Building(PM,Ntail)
% Pili_Type_Building This function is used to construct the desired type of pili morphology
% e.g. Pili_str = Pili_Type_Building(PM,Ntail)
% Created by: Lucien
% E-mail: lucien-6@qq.com
% 2024-10-10
% Modified by: Lucien       Last modified: 2026-08-18 (V1.1.1)

if Ntail < 2
    Pili_str = struct('rxtail', [], 'rytail', [], 'rztail', [], ...
        'gxtail', [], 'gytail', [], 'gztail', []);
    return
end

Pili_Type = PM(1); %Type of pili
L_helix = PM(2); %Length of pili
theta = PM(3); %Angle of posture of the pili relative to the z-axis
gama = PM(4); %Angle of posture of the pili relative to the x-axis

RZ = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
RX = [1,0,0;0,cos(gama),sin(gama);0 -sin(gama) cos(gama)];
RM = RX*RZ; %pili deflection matrix

switch Pili_Type

    case 1

    %Linear
    L_helix = L_helix*1e-6;
    rxtail = 0.0:L_helix/(Ntail-1):L_helix;
    rytail = zeros(1,Ntail);
    rztail = zeros(1,Ntail);

    case 2

    %Parabolic
    K = PM(5);
    L_helix =  0:K*L_helix/(Ntail-1):K*L_helix;
    XEnd =  -0.0002146*L_helix.^6+0.004265*L_helix.^5 -0.0352*L_helix.^4+0.1586*L_helix.^3 ...
        -0.4459*L_helix.^2+1.087*L_helix -0.004127;
    rxtail = XEnd/K;
    rytail = rxtail.^2.0;
    rxtail = rxtail.*1e-6;
    rytail = rytail.*1e-6;
    rztail = zeros(1,Ntail);

    case 3

    %Circular
    L_helix = L_helix*1e-6;
    Angle_Circle = PM(5);
    Dtheta = 0:Angle_Circle/(Ntail-1):Angle_Circle;
    rxtail = L_helix/Angle_Circle.*sin(Dtheta);
    rytail = L_helix/Angle_Circle.*(1.0-cos(Dtheta));
    rztail = zeros(1,Ntail);

    case 4

    %Expansive sinusoidal
    a = PM(5);
    b = PM(6);
    x = 0:0.001:4;
    y = a.*x.*cos(b*x);
    n = length(x);
    L = zeros(1,n);
    for i = 2:n
        L(i) = L(i-1)+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
    end
    [~,index] = min(abs(L_helix-L));
    XEnd = x(index);
    rxtail = 0.0:XEnd/(Ntail-1):XEnd;
    rytail = a.*rxtail.*cos(b*rxtail);
    rztail = zeros(1,Ntail);
    rxtail = rxtail.*1e-6;
    rytail = rytail.*1e-6;
    rztail = rztail.*1e-6;

    case 5

    %Conical spiral
    a = PM(5);
    b = PM(6);
    c = PM(7);
    t = 0:0.001:4;
    x = a.*t.*cos(c.*t);
    y = a.*t.*sin(c.*t);
    z = b.*t;
    n = length(t);
    L = zeros(1,n);
    for i = 2:n
        L(i) = L(i-1)+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2+(z(i)-z(i-1))^2);
    end
    [~,index] = min(abs(L_helix-L));
    tEnd = t(index);
    t = 0.0:tEnd/(Ntail-1):tEnd;
    rytail = a.*t.*cos(c.*t);
    rztail = a.*t.*sin(c.*t);
    rxtail = b.*t;
    rxtail = rxtail.*1e-6;
    rytail = rytail.*1e-6;
    rztail = rztail.*1e-6;

    otherwise

        errordlg('Some type of pili not available !','ERROR')

end

%Deflection of pili posture
T = RM*[rxtail;rytail;rztail];
rxtail = T(1,:);
rytail = T(2,:);
rztail = T(3,:);

gxtail = rxtail;
gytail = rytail;
gztail = rztail;

% %Drawing the final image of pili morphology
% figure('Name','Schematic diagram of pili morphology')
% set(gcf,'unit','centimeters','position',[15,15,30,15]);
% plot3(rxtail,rytail,rztail,'.B',gxtail,gytail,gztail,'or');
% title('Image of Pili Morphology');
% xlabel('X');ylabel('Y');zlabel('Z');
% legend('Location points','Force points');

Pili_str = struct('rxtail',rxtail,'rytail',rytail,'rztail',rztail,'gxtail',gxtail,'gytail',gytail,'gztail',gztail);

end
