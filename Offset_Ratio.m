function OR = Offset_Ratio(Trajectory)
%Offset_Ratio This function is used to calculate the offset curve of particle.
%   This function is used to compute the offset ratio-time curve of a particle 
%   based on its three-dimensional motion trajectory. The input is the trajectory 
%   of the particle, which is stored as an N×4 matrix in the format of (t,x,y,z); 
%   the output is the offset rate-time data of the particle, which is output in the 
%   format of an N×2 matrix, with the first column being the delay time and the 
%   second column being the offset ratio.

Num = length(Trajectory(:,1));
OR = zeros(Num-1,2);
OR(:,1) = Trajectory(2:end,1);%Time sequence

Temp = zeros(Num-1,Num-1);

for m = 1:Num-1
    YZ = vecnorm((Trajectory(m+1:end,3:4)-Trajectory(m,3:4)),2,2);
    X = Trajectory(m+1:end,2)-Trajectory(m,2);
    Temp(1:end+1-m,m) = atan(YZ./X); 
end

Temp(Temp==0) = NaN;
OR(:,2) = mean(Temp,2,'omitmissing')'; %Offset ratio

end