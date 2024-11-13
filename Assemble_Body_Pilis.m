function Assem_str = Assemble_Body_Pilis(Nhead,bHead,pili,major_axis)
% Assemble_Body_Pilis This function is used to assemble the bacterial theme and pili together
% e.g. Assem_str = Assemble_Body_Pilis(Nhead,bHead,pili,major_axis)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

% Bacterial body shifting
rxH = bHead.rxS(1:Nhead)' + major_axis;
ryH = bHead.ryS(1:Nhead)';
rzH = bHead.rzS(1:Nhead)';
gxH = bHead.gxS(1:Nhead)' + major_axis;
gyH = bHead.gyS(1:Nhead)';
gzH = bHead.gzS(1:Nhead)';

% Pili part
rxT = pili.rxT;
ryT = pili.ryT;
rzT = pili.rzT;
gxT = rxT;
gyT = ryT;
gzT = rzT;
NPili = pili.NPili;
Ntail = pili.Ntail;
NTail = pili.NTail;
NPoint = pili.NPoint;
APoint = pili.APoint;

if NTail ~=0
    NBac = Nhead+NTail;
    %Assemble body and pilis
    rxBac = [rxH rxT];
    ryBac = [ryH ryT];
    rzBac = [rzH rzT];

    gxBac = [gxH gxT];
    gyBac = [gyH gyT];
    gzBac = [gzH gzT];
else
    NBac = Nhead;

    rxBac = rxH;
    ryBac = ryH;
    rzBac = rzH;

    gxBac = gxH;
    gyBac = gyH;
    gzBac = gzH;

end

% %Plotting bacterial modeling results
% figure('Name','Resulting image after assembly')
% set(gcf,'unit','centimeters','position',[15,15,40,15]);
% plot3(rxH,ryH,rzH,'.B',gxH,gyH,gzH,'.r',rxT,ryT,rzT,'.B',gxT,gyT,gzT,'^R');
% title('3D Schematic of Bacteria Model');
% xlabel('X');ylabel('Y');zlabel('Z');
% legend('Location points','Force points');
% axis equal;


Assem_str = struct('rxH',rxH,'ryH',ryH,'rzH',rzH,'gxH',gxH,'gyH',gyH,'gzH',gzH,'rxT',rxT,'ryT',ryT,'rzT',rzT,'gxT',gxT,'gyT',gyT,'gzT',gzT,'rxBac',rxBac,'ryBac',ryBac,'rzBac',rzBac,...
    'gxBac',gxBac,'gyBac',gyBac,'gzBac',gzBac,'NPili',NPili,'Ntail',Ntail,'NTail',NTail,'NPoint',NPoint,'APoint',APoint,'NBac',NBac);

end

