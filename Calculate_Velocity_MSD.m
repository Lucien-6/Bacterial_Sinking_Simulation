function VM = Calculate_Velocity_MSD(Pos,TStep,Case_Name,Tlim,Output_Path)
% Calculate_Velocity_MSD This function is used to calculate the velocity and MSD of bacteria
% e.g. VM = Calculate_Velocity_MSD(Pos,Case_Name,Output_Path)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-15

P = Pos(1:3,:)'.*1e6;
VM = zeros(length(P(:,1))-1,8);
VM(:,1) = ((0:length(P(:,1))-2)*TStep)';
VM(:,2:4) = (P(2:end,:)-P(1:end-1,:))./TStep; %Velocity at X/Y/Z directions
VM(:,5) = vecnorm(VM(:,2:4),2,2); %Total Velocity
VM(:,6) = (P(2:end,1)-P(1,1))./(VM(:,1)+TStep); %Sinking Velocity
%Calculate the MSD
Temp = zeros(length(P(:,1)),length(P(:,1)));

for j = 1:length(P(:,1))-1
    Temp(1:end+1-j,j) = (vecnorm((P(j:end,:)-P(j,:)),2,2)).^2;
end

Temp(Temp==0) = NaN;
Temp(1,:) = [];

VM(:,7) = VM(:,1)+TStep;
VM(:,8) = mean(Temp,2,'omitmissing')'; %MSD

%Plot the Time-Total Velocity curve
figure('Name','Time&TotalVelocity curve')
set(gcf,'position',[20,20,1500,750])
P1 = plot(VM(:,1),VM(:,5),'r','LineWidth',2);
set(gca,'FontName','Times New Roman')
ax = gca; ax.LineWidth = 1.5;ax.FontSize = 12;
title('Time&Total Velocity curve','FontSize',32,'FontWeight','bold')
xlabel('Time (s)','FontSize',20);ylabel('Total Velocity (μm/s)','FontSize',20)
grid on
%Plot the mean value line
hold on
P2 = line([VM(1,1) VM(end,1)],...
    [mean(VM(:,5)) mean(VM(:,5))],...
    'Color','b','LineWidth',1.5,'LineStyle','--');
text(VM(end,1),mean(VM(:,5)),['\leftarrow ',num2str(mean(VM(:,5)))],'Color','b','FontSize',14, ...
    'FontName','Times New Roman')
legend([P1,P2],{'Instantaneous Velocity','Mean Velocity'})
saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_TotalVelocity'],'png')%Save this figure

%Plot the Time-Sinking Velocity curve
figure('Name','Time&SinkingVelocity curve')
set(gcf,'position',[20,20,1500,750])
plot(VM(:,1),VM(:,6),'r','LineWidth',2)
set(gca,'FontName','Times New Roman')
ax = gca; ax.LineWidth = 1.5;ax.FontSize = 12;
title('Time&Sinking Velocity curve','FontSize',32,'FontWeight','bold')
xlabel('Time (s)','FontSize',20);ylabel('Sinking Velocity (μm/s)','FontSize',20)
grid on
text(VM(end,1),VM(end,6),['\leftarrow ',num2str(VM(end,6))],'Color','red','FontSize',14, ...
    'FontName','Times New Roman')
saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_SinkingVelocity'],'png')%Save this figure

%Plot the MSD
figure('Name','MSD')
set(gcf,'Position',[20 20 1200 1000])
L1 = loglog(VM(:,7),VM(:,8),'LineWidth',2.5);
set(gca,'FontName','Times New Roman')
grid on
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
title('Mean-Square Displacement','FontSize',24,'FontWeight','bold')
xlabel('Δt (s)','FontSize',18);ylabel('MSD (μm^2)','FontSize',18);
xlim([VM(1,1) 1.5*VM(end,1)])
%Plot a reference straight line segment with a slope of 1
hold on
L2 = line([0.002*VM(end,1) 0.1*VM(end,1)],...
    [0.002*VM(end,1) 0.1*VM(end,1)],...
    'Color','k','LineWidth',1.5,'LineStyle','--');
legend([L1,L2],{'Simulation Data','log(Y) = log(X)'},'FontSize',16,'Location','southeast')

saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_MSD'],'png')%Save this figure

%Fitting the MSD curve
figure('Name','Fitting MSD')
set(gcf,'Position',[20 20 1200 1000])
ExlcudeData = VM(:,7)<Tlim(1) | VM(:,7)>Tlim(2);
[fo,gof] = fit(VM(:,7),VM(:,8),'poly2','Lower',[0 0 0],'Upper',[Inf Inf 0],'Exclude',ExlcudeData);
L3 = plot(fo,'--r',VM(:,7),VM(:,8),'-b',ExlcudeData,'.b');
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
text(Tlim(2),fo(Tlim(2)),latexf,'Interpreter','latex','FontSize',14,'Color','k','HorizontalAlignment','right')

saveas(gcf,[Output_Path,'/',Case_Name,'/',Case_Name,'_Fitted-MSD'],'png')%Save this figure

end  