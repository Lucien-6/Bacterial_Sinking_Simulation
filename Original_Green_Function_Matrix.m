function Mall = Original_Green_Function_Matrix(bac,Nhead,NALL,epsA,Miu)
% Original_Green_Function_Matrix This function is used to construct the original Green's function matrix
% e.g. Mall = Original_Green_Function_Matrix(bac,Nhead,NALL,epsA,Miu)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

rx=[bac.rxBac;bac.ryBac;bac.rzBac];
X=[bac.gxBac;bac.gyBac;bac.gzBac];

rn = size(rx,2);
fn = size(X,2);

MSxx = zeros(rn, fn);
MSxy = zeros(rn, fn);
MSxz = zeros(rn, fn);
MSyx = zeros(rn, fn);
MSyy = zeros(rn, fn);
MSyz = zeros(rn, fn);
MSzx = zeros(rn, fn);
MSzy = zeros(rn, fn);
MSzz = zeros(rn, fn);

% Calculate the Green's function tensor matrix G(r) from the force point action to the surface location point

for b = 1:rn
    for k = 1:fn
        disx = rx(1,b) - X(1,k);
        disy = rx(2,b) - X(2,k);
        disz = rx(3,b) - X(3,k);
        r2sk = disx^2+disy^2+disz^2;%ΔL²
        rsk = r2sk^0.5;%ΔL
        r3sk = r2sk^1.5;%ΔL³

        if  k>Nhead && k<=NALL %The regularized Stokes method was applied to the pilis

            a2   = epsA^2;
            H1sk = 8*pi / (8*pi^1.5);

            B1k=(2.0*exp(-rsk^2/a2))/epsA;

            if(r2sk==0)
                B2k=2.0/epsA;
                B3k=4/3;
            else
                B2k=sqrt(pi)*erf(rsk/epsA)/rsk;
                B3k=((-2.0*exp(-r2sk/a2)*rsk/epsA)+sqrt(pi)*erf(rsk/epsA))/r3sk;
            end

            MSxx(b,k) = (B1k+B2k+B3k*disx^2)*H1sk;
            MSyx(b,k) = disy*disx*H1sk*B3k;
            MSxy(b,k) = MSyx(b,k);
            MSyy(b,k) = (B1k+B2k+B3k*disy^2)*H1sk;
            MSxz(b,k) = disx*disz*H1sk*B3k;
            MSyz(b,k) = disy*disz*H1sk*B3k;
            MSzx(b,k) = MSxz(b,k);
            MSzy(b,k) = MSyz(b,k);
            MSzz(b,k) = (B1k+B2k+B3k*disz^2)*H1sk;
   
            % %This paragraph uses the smoothing function recommended in Cortez, et al. (2005) DOI: 10.1063/1.1830486
            % e2 = epsA^2;
            % H1sk = (r2sk+e2)^(3/2);
            % 
            % MSxx(b,k) = ((r2sk+2*e2)+disx^2)/H1sk;
            % MSyx(b,k) = disy*disx/H1sk;
            % MSxy(b,k) = MSyx(b,k);
            % MSyy(b,k) = ((r2sk+2*e2)+disy^2)/H1sk;
            % MSxz(b,k) = disx*disz/H1sk;
            % MSyz(b,k) = disy*disz/H1sk;
            % MSzx(b,k) = MSxz(b,k);
            % MSzy(b,k) = MSyz(b,k);
            % MSzz(b,k) = ((r2sk+2*e2)+disz^2)/H1sk;

        else

            H1sk = 1.0 / (r3sk);

            MSxx(b,k) = ((r2sk)+disx^2)*H1sk;
            MSyx(b,k) = disy*disx*H1sk;
            MSxy(b,k) = MSyx(b,k);
            MSyy(b,k) = ((r2sk)+disy^2)*H1sk;
            MSxz(b,k) = disx*disz*H1sk;
            MSyz(b,k) = disy*disz*H1sk;
            MSzx(b,k) = MSxz(b,k);
            MSzy(b,k) = MSyz(b,k);
            MSzz(b,k) = ((r2sk)+disz^2)*H1sk;
        end
    end
end

Mall = [MSxx MSxy MSxz;MSyx MSyy MSyz;MSzx MSzy MSzz]./(8*pi*Miu);

end