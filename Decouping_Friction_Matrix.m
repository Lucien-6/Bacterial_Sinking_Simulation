function DFM = Decouping_Friction_Matrix(FM)
% Decouping_Friction_Matrix This function is used to decoupling the friction matrix
% e.g. DFM = Decouping_Friction_Matrix(FM)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-30

A = FM(1:3,1:3);
B = FM(1:3,4:6);
C = FM(4:6,1:3);
D = FM(4:6,4:6);

DFM = zeros(6,6);

DFM(1:3,1:3) = A-B/D*C;
DFM(4:6,4:6) = D-C/A*B;

end