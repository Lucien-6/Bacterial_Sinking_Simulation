function OR = Offset_Ratio(Trajectory)
%Offset_Ratio Compute offset statistics along a particle trajectory.
%   Input: Trajectory is an N×4 matrix (t, x, y, z).
%   Output: OR is an (N-1)×4 matrix:
%       col1 - delay time
%       col2 - offset ratio = mean lateral displacement / mean axial displacement
%       col3 - mean lateral displacement in YZ
%       col4 - mean axial displacement in X
% Created by: Lucien
% E-mail: lucien-6@qq.com
% Modified: 2026-07-31 (V1.1.0)

Num = length(Trajectory(:,1));
OR = zeros(Num-1,4);
OR(:,1) = Trajectory(2:end,1);%Time sequence

Temp1 = zeros(Num-1,Num-1);
Temp2 = zeros(Num-1,Num-1);

for m = 1:Num-1
    Temp1(1:end+1-m,m) = vecnorm((Trajectory(m+1:end,3:4)-Trajectory(m,3:4)),2,2);
    Temp2(1:end+1-m,m) = Trajectory(m+1:end,2)-Trajectory(m,2);
end

Temp1(Temp1==0) = NaN;
Temp2(Temp2==0) = NaN;
OR(:,3) = mean(Temp1,2,'omitmissing')'; 
OR(:,4) = mean(Temp2,2,'omitmissing')'; 

% Offset ratio (lateral / axial); protect near-zero axial mean
OR(:,2) = OR(:,3) ./ OR(:,4);
tiny_axial = abs(OR(:,4)) < 1e-15 | isnan(OR(:,4));
OR(tiny_axial, 2) = NaN;

end
