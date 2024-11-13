function [rxT,ryT,rzT,APoint,PV] = Pili_Location(hTail,dis,major_axis,minor_axis,j,rxT,ryT,rzT,NPoint,Ntail)
% Pili_Location This function is used to fix pili to specific points on the surface of the body
% e.g. [rxT,ryT,rzT,APoint,PV] = Pili_Location(hTail,dis,major_axis,minor_axis,j,rxT,ryT,rzT,NPoint,Ntail)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10


switch NPoint(j)
    case 1
        if j ==1
            rxT(1:Ntail(1)) = 0-dis-hTail.rxtail;
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = 0-dis-hTail.rxtail;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [-dis 0 0];
        PV = [-1 0 0];
    case 2
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+minor_axis;
            ryT(1:Ntail(1)) = dis+hTail.rxtail+minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = dis+hTail.rxtail+minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [minor_axis minor_axis+dis 0];
        PV = [0 1 0];
    case 3
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+minor_axis;  
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = -hTail.rxtail-dis-minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -hTail.rxtail-dis-minor_axis;
        end
        APoint = [minor_axis 0 -minor_axis-dis];
        PV = [0 0 -1];
    case 4
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+minor_axis;
            ryT(1:Ntail(1)) = -dis-hTail.rxtail-minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -dis-hTail.rxtail-minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [minor_axis -minor_axis-dis 0];
        PV = [0 -1 0];
    case 5
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+minor_axis;
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = hTail.rxtail+dis+minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rxtail+dis+minor_axis;
        end
        APoint = [minor_axis 0 minor_axis+dis];
        PV = [0 0 1];
    case 6
        if j ==1
            rxT(1:Ntail(1)) = dis+hTail.rxtail+2*major_axis;
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = dis+hTail.rxtail+2*major_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [2*major_axis+dis 0 0];
        PV = [1 0 0];
    case 7
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+2*major_axis-minor_axis;
            ryT(1:Ntail(1)) = dis+hTail.rxtail+minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+2*major_axis-minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = dis+hTail.rxtail+minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [2*major_axis-minor_axis minor_axis+dis 0];
        PV = [0 1 0];
    case 8
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+2*major_axis-minor_axis;  
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = -hTail.rxtail-dis-minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+2*major_axis-minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -hTail.rxtail-dis-minor_axis;
        end
        APoint = [2*major_axis-minor_axis 0 -minor_axis-dis];
        PV = [0 0 -1];
    case 9
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+2*major_axis-minor_axis;
            ryT(1:Ntail(1)) = -dis-hTail.rxtail-minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+2*major_axis-minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -dis-hTail.rxtail-minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [2*major_axis-minor_axis -minor_axis-dis 0];
        PV = [0 -1 0];
    case 10
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+2*major_axis-minor_axis;
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = hTail.rxtail+dis+minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+2*major_axis-minor_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rxtail+dis+minor_axis;
        end
        APoint = [2*major_axis-minor_axis 0 minor_axis+dis];
        PV = [0 0 1];
    case 11
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+major_axis;
            ryT(1:Ntail(1)) = dis+hTail.rxtail+minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+major_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = dis+hTail.rxtail+minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [major_axis minor_axis+dis 0];
        PV = [0 1 0];
    case 12
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+major_axis;  
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = -hTail.rxtail-dis-minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+major_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -hTail.rxtail-dis-minor_axis;
        end
        APoint = [major_axis 0 -minor_axis-dis];
        PV = [0 0 -1];
    case 13
        if j ==1
            rxT(1:Ntail(1)) = hTail.rytail+major_axis;
            ryT(1:Ntail(1)) = -dis-hTail.rxtail-minor_axis;
            rzT(1:Ntail(1)) = hTail.rztail;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail+major_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = -dis-hTail.rxtail-minor_axis;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail;
        end
        APoint = [major_axis -minor_axis-dis 0];
        PV = [0 -1 0];
    case 14
        if j ==1
            rxT(1:Ntail(1)) = hTail.rztail+major_axis;
            ryT(1:Ntail(1)) = hTail.rytail;
            rzT(1:Ntail(1)) = hTail.rxtail+dis+minor_axis;
        else
            rxT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rztail+major_axis;
            ryT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rytail;
            rzT(sum(Ntail(1:j-1))+1:sum(Ntail(1:j))) = hTail.rxtail+dis+minor_axis;
        end
        APoint = [major_axis 0 minor_axis+dis];
        PV = [0 0 1];
    otherwise
        errordlg('Some loci are not available !','ERROR')
end
end

