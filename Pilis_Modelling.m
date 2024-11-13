function pili = Pilis_Modelling(Pili_Matrix,ppp,major_axis,minor_axis,dis)
% Pilis_Modelling This function is used to construct the pili model
% e.g. pili = Pilis_Modelling(Pili_Matrix,ppp,major_axis,minor_axis,dis)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

NPili = length(Pili_Matrix(1,:)); %Number of pili

Ntail = ceil(Pili_Matrix(2,:).*ppp);
NTail = sum(Ntail);
rxT = zeros(1,NTail);
ryT = zeros(1,NTail);
rzT = zeros(1,NTail);
APoint = zeros(NPili,3);
PVector = zeros(NPili,3);
NPoint = Pili_Matrix(8,:);

for  j = 1:NPili
    hTail = Pili_Type_Building(Pili_Matrix(1:7,j),Ntail(j)); %Constructing
    [rxT,ryT,rzT,APoint(j,:),PVector(j,:)] = Pili_Location(hTail,dis,major_axis,minor_axis,j,rxT,ryT,rzT,NPoint,Ntail); %Localizing
end

pili = struct('rxT',rxT,'ryT',ryT,'rzT',rzT,'NPili',NPili,'Ntail',Ntail,'NTail',NTail,'NPoint',NPoint,'APoint',APoint,'PVector',PVector,'Pili_Matrix',Pili_Matrix);

end

