function pili = Pilis_Modelling(Pili_Matrix,ppp,major_axis,minor_axis,dis)
% Pilis_Modelling This function is used to construct the pili model
% e.g. pili = Pilis_Modelling(Pili_Matrix,ppp,major_axis,minor_axis,dis)
% Use Pili_Matrix = zeros(8,0) for a true no-pili body.
% Columns with non-positive length are skipped (Ntail=0).
% Created by: Lucien
% E-mail: lucien-6@qq.com
% 2024-10-10
% Modified by: Lucien       Last modified: 2026-08-18 (V1.1.1)

if isempty(Pili_Matrix) || size(Pili_Matrix, 2) == 0
    pili = struct( ...
        'rxT', [], 'ryT', [], 'rzT', [], ...
        'NPili', 0, 'Ntail', [], 'NTail', 0, ...
        'NPoint', [], 'APoint', zeros(0, 3), 'PVector', zeros(0, 3), ...
        'Pili_Matrix', Pili_Matrix);
    return
end

NPili = size(Pili_Matrix, 2); %Number of pili columns
lengths = Pili_Matrix(2, :);
Ntail = zeros(1, NPili);
for j = 1:NPili
    if lengths(j) > 0
        Ntail(j) = ceil(lengths(j) * ppp);
        if Ntail(j) < 2
            % Need at least 2 sample points to build a curve segment
            Ntail(j) = 0;
        end
    end
end

NTail = sum(Ntail);
rxT = zeros(1, NTail);
ryT = zeros(1, NTail);
rzT = zeros(1, NTail);
APoint = zeros(NPili, 3);
PVector = zeros(NPili, 3);
NPoint = Pili_Matrix(8, :);

for j = 1:NPili
    if Ntail(j) == 0
        continue
    end
    hTail = Pili_Type_Building(Pili_Matrix(1:7, j), Ntail(j)); %Constructing
    [rxT, ryT, rzT, APoint(j, :), PVector(j, :)] = Pili_Location( ...
        hTail, dis, major_axis, minor_axis, j, rxT, ryT, rzT, NPoint, Ntail); %Localizing
end

pili = struct('rxT', rxT, 'ryT', ryT, 'rzT', rzT, 'NPili', NPili, ...
    'Ntail', Ntail, 'NTail', NTail, 'NPoint', NPoint, ...
    'APoint', APoint, 'PVector', PVector, 'Pili_Matrix', Pili_Matrix);

end
