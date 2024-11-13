function Model_Checking(bac)
% Model_Checking This function is used to detect if there is a mold penetration error in the bacterial model
% e.g. Model_Checking(bac)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

shp = alphaShape(bac.rxH',bac.ryH',bac.rzH',Inf);
RT = [bac.rxT' bac.ryT' bac.rzT'];
TF = inShape(shp,RT);
N = sum(TF==1);

if N>0
    figure('Name','Image of the wrong bacterial model')
    set(gcf,'unit','centimeters','position',[15,15,25,20]);
    plot3(bac.rxH.*1e6,bac.ryH.*1e6,bac.rzH.*1e6,'.B',bac.rxT.*1e6,bac.ryT.*1e6,bac.rzT.*1e6,'.r','MarkerSize',2);
    title('Image of the wrong bacterial model');
    xlabel('X (μm) ');ylabel('Y(μm)');zlabel('Z(μm)');
    legend('Body','Pilis');
    axis equal;

    error('As shown in the figure, the bacterial body has overlapped with the pilis!')

end

end

