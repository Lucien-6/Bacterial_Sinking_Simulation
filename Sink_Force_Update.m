function [Q,US] = Sink_Force_Update(m,Sink_Theta,TStep,Velocity_Log,Force_Direct)
% Sink_Force_Update This function is used to update the vector of sinking forces in the Lagrangian coordinate system
% e.g. [trans,US] = Sink_Force_Update(i,Sink_Theta,TStep,Velocity_Log,Force_Direct)
% Created by: Lucien
% E-mail: lucien-6@qq.com
% 2024-10-10
% Modified by: Lucien       Last modified: 2026-08-18 (V1.1.1)
%   - Guard against zero angular increment (avoid W./Theta -> NaN)

if m == 1 && any(Sink_Theta)%Separate assignment for the first step
    Theta = norm(Sink_Theta);
    Rot_Axis = Sink_Theta./Theta; 
elseif m == 1 && ~any(Sink_Theta)
    Theta = 0;
    Rot_Axis = [1,0,0]; 
else
    W = Velocity_Log(4:6,m-1)'*TStep;
    Theta = norm(W);
    if Theta < 1e-15
        Theta = 0;
        Rot_Axis = [1,0,0]; % unused when Theta==0 (sin(Theta/2)==0)
    else
        Rot_Axis = W./Theta;
    end
end

%Construct the quaternion needed for rotation
Q = quaternion([cos(Theta/2),sin(Theta/2)*Rot_Axis]);

%Conversion of sinking force vectors to quaternions
V = quaternion([0,Force_Direct']);

% Calculate the sinking force vector in the Lagrangian coordinate system at step i
Temp = conj(Q)*V*Q;
[~,x,y,z] = parts(Temp);
US = [x;y;z];

end
