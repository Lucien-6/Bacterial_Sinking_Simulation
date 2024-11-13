function Pos = Calculate_Motion_Trajectory(TNum,major_axis,Velocity_Log,TStep,Trans,Case_Name,Output_Path)
% Calculate_Motion_Trajectory This function is used to calculate and plot the trajectory of the bacteria in the Eulerian coordinate system
% e.g. Pos = Calculate_Motion_Trajectory(TNum,major_axis,Velocity_Log,TStep,Trans,Case_Name,Output_Path)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

Pos = zeros(9,TNum);
fprintf(['\nProgress: ',repmat(' ', 1, 6)])
for j = 1:TNum
    RA = [major_axis;0;0];
    RA = quaternion([0,RA']);
    if j ==1 %Separate assignment for the first step
        Pos(1:3,j) = zeros(3,1);
        RA = Trans{1}*RA*conj(Trans{1});
        [~,x2,y2,z2] = parts(RA);
        Pos(4:6,j) = [x2;y2;z2];
    else
        %Cumulative inverse rotation computation for solving bacterial trajectory in Eulerian coordinate system
        DR = [Velocity_Log(1,j-1);Velocity_Log(2,j-1);Velocity_Log(3,j-1)].*TStep;
        DR = quaternion([0,DR']);
        for m = j:-1:2
            DR2 = Trans{m-1}*DR*conj(Trans{m-1});
            DR = DR2;
            RA2 = Trans{m-1}*RA*conj(Trans{m-1});
            RA = RA2;
        end
        [~,x1,y1,z1] = parts(DR);
        [~,x2,y2,z2] = parts(RA);
        Pos(1:3,j) = Pos(1:3,j-1)+[x1;y1;z1]; %Centroid coordinate
        Pos(4:6,j) = Pos(1:3,j)+[x2;y2;z2]; %Coordinates of the one pole
    end
    fprintf(repmat('\b', 1, 6))
    fprintf('%5.2f%%',100*j/TNum)
end

Pos(7:9,:) = Pos(1:3,:).*2.0-Pos(4:6,:); %Use the midpoint property to solve for the other pole

figure('Name','Bacterial Trajectory')
plot3(Pos(3,:).*1e6,Pos(2,:).*1e6,Pos(1,:).*1e6,'-r','MarkerSize',2)
set(gca,'ZDir','reverse','FontName','Times New Roman')
title('Bacterial Trajectory','FontSize',14,'FontName','Times New Roman','FontWeight','bold')
xlabel('Z / μm');ylabel('Y / μm');zlabel('X / μm')
axis equal;grid on;
% view(90,90); %Adjust the viewing angle to the XY plane

saveas(gcf, [Output_Path,'/',Case_Name,'/',Case_Name,'_Trajectory.jpg']);
save([Output_Path,'/',Case_Name,'/',Case_Name,'_Pos.mat'],'Pos') %Save results

end