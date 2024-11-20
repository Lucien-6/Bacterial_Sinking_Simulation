function Bacteria_Motion_Animations(Case_Name,TStep,major_axis,TNum,bac,PR,Trans,Velocity_Log,Pos,Output_Path)
% Bacteria_Motion_Animations This function is used to animate the motion of bacteria in the Eulerian coordinate system
% e.g. Bacteria_Motion_Animations(Case_Name,TStep,major_axis,TNum,bac,PR,Trans,Velocity_Log,Pos,Output_Path)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

avi_object = VideoWriter([Output_Path,'/',Case_Name,'/',Case_Name,'_Bac_Movie.mp4']);
avi_object.FrameRate = 1/TStep;
avi_object.Quality = 90;
open(avi_object);
avi_figure = figure;
set(gcf,'position',[10,10,750,1500]);

Body = [bac.rxH;bac.ryH;bac.rzH]-[major_axis;0;0];
BB = Body'.*1e6;
BB = quaternion([zeros(bac.NBac-bac.NTail,1),BB]);
Center = zeros(3,TNum);

%Axis range
RL = max(Pos(1:3,:),[],2)+1e-5;
LL = min(Pos(1:3,:),[],2)-1e-5;

for n = 1:TNum
    Pili = PR{n};
    Pili = Pili-[major_axis;0;0];
    PP = Pili'.*1e6;
    PP = quaternion([zeros(bac.NTail,1),PP]);
    if n == 1
        Temp1 = Trans{1}*BB*conj(Trans{1});
        Temp2 = Trans{1}*PP*conj(Trans{1});
        [~,x2,y2,z2] = parts(Temp1);
        [~,x3,y3,z3] = parts(Temp2);
        B = [x2';y2';z2'];
        P = [x3';y3';z3'];
    else
        DR = [Velocity_Log(1,n-1);Velocity_Log(2,n-1);Velocity_Log(3,n-1)].*(TStep*1e6);
        DR = quaternion([0,DR']);
        for m = n:-1:2
            DR2 = Trans{m-1}*DR*conj(Trans{m-1});
            DR = DR2;
            Temp1 = Trans{m-1}*BB*conj(Trans{m-1});
            BB = Temp1;
            Temp2 = Trans{m-1}*PP*conj(Trans{m-1});
            PP = Temp2;
        end
        [~,x1,y1,z1] = parts(DR);
        [~,x2,y2,z2] = parts(BB);
        [~,x3,y3,z3] = parts(PP);
        B = [x2';y2';z2'];
        P = [x3';y3';z3'];
        Center(:,n) = Center(:,n-1)+[x1;y1;z1];
        B = B+Center(:,n);
        P = P+Center(:,n);
    end
    %Draw pilis
    if ~isempty(P)
        p1 = plot3(P(3,:),P(2,:),P(1,:),'ob','MarkerSize',1,'MarkerFaceColor','b');
    end
    set(gca,'ZDir','reverse','FontName','Times New Roman','LineWidth',1.5)
    title(['Bacteria Motion Animation (T=',num2str((n-1)*TStep,'%06.2f'),' s)'],...
        'FontSize',18,'FontWeight','bold')
    xlabel('Z / μm');ylabel('Y / μm');zlabel('X /μm')
    axis equal
    axis([LL(3) RL(3) LL(2) RL(2) LL(1) RL(1)].*1e6)
    view(90,0)
    % view(30,30)
    grid on
    hold on
    %Draw body
    XTemp = linspace(min(B(1,:)),max(B(1,:)),500);
    YTemp = linspace(min(B(2,:)),max(B(2,:)),500);
    [X,Y] = meshgrid(XTemp,YTemp);
    Z = griddata(B(1,:),B(2,:),B(3,:),X,Y,'linear');
    p2 = surf(Z,Y,X,'FaceColor',[35, 139, 42]./255,'EdgeColor','none','FaceAlpha',0.7);
    hold on
    %Draw the centroid of body
    p3 = plot3(Center(3,n),Center(2,n),Center(1,n),'hexagramr','MarkerSize',5,'MarkerFaceColor','b',...
        'MarkerEdgeColor','b');
    hold on
    %Draw trajectory
    p4 = plot3(Center(3,1:n),Center(2,1:n),Center(1,1:n),'-r','MarkerSize',2);
    %Draw legend
    if isempty(P)
        legend([p2,p3,p4],{'Body','Centroid','Trajectory'},'Location','southeast','LineWidth',1.0)
    else
        legend([p1,p2,p3,p4],{'Pilis','Body','Centroid','Trajectory'},'Location','southeast','LineWidth',1.0)
    end
    hold off;
    
    avi_frame = getframe(avi_figure);
    writeVideo(avi_object,avi_frame);
    
    clf
end

close(avi_figure)
close(avi_object)

end



