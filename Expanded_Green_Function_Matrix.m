function M = Expanded_Green_Function_Matrix(NALL,Nhead,bac,major_axis,Mall)
% Expanded_Green_Function_Matrix This function is used to construct the
% expand Green's function matrix for the conditions of joint force balance and no slip on the surface.
% e.g. M = Expanded_Green_Function_Matrix(NALL,Nhead,bac,major_axis,Mall)
% Created by: Lucien
% E-mail: 2531989856@qq.com
% 2024-10-10

Mb = zeros(6,3*NALL);
Mr = zeros(3*NALL,6);

NTail = bac.NTail;

if NTail ~= 0 %when there are pilis

    %Joint force balance
    Mb(1,:)=repmat([1 0 0],1,NALL); %Joint force in x-direction
    Mb(2,:)=repmat([0 1 0],1,NALL); %Joint force in y-direction
    Mb(3,:)=repmat([0 0 1],1,NALL); %Joint force in z-direction
    % Total torque in x-direction
    temp1=[zeros(Nhead,1) -(bac.gzH') (bac.gyH')]';
    temp2=[zeros(NTail,1)    -bac.gzT' bac.gyT']';
    Mb(4,:)=[temp1(:)' temp2(:)'];
    % Total torque in y-direction
    temp1=[(bac.gzH') zeros(Nhead,1) -(bac.gxH'-major_axis)]';
    temp2=[bac.gzT' zeros(NTail,1) -(bac.gxT'-major_axis)]';
    Mb(5,:)=[temp1(:)' temp2(:)'];
    % Total torque in z-direction
    temp1=[-(bac.gyH') (bac.gxH'-major_axis) zeros(Nhead,1)]';
    temp2=[-bac.gyT' (bac.gxT'-major_axis) zeros(NTail,1)]';
    Mb(6,:)=[temp1(:)' temp2(:)'];
    %Synthesizing a six-degree-of-freedom joint force matrix
    Mb=[Mb(:,1:3:3*(NALL)) Mb(:,2:3:3*(NALL)) Mb(:,3:3:3*(NALL)) zeros(6,6)];

    % No slip on the surface
    Mr(:,1)=repmat([-1 0 0]',NALL,1); %Combined velocity in x-direction
    Mr(:,2)=repmat([0 -1 0]',NALL,1); %Combined velocity in y-direction
    Mr(:,3)=repmat([0 0 -1]',NALL,1); %Combined velocity in z-direction
    %X-direction velocity due to Y- and Z-direction rotation
    temp1=[zeros(Nhead,1) (bac.rzH') -(bac.ryH')]';
    temp2=[zeros(NTail,1)  bac.gzT' -bac.gyT']';
    Mr(:,4)=[temp1(:);temp2(:)];
    %Y-direction velocity due to X- and Z-direction rotation
    temp1=[-(bac.rzH') zeros(Nhead,1) (bac.rxH'-major_axis)]';
    temp2=[-bac.gzT' zeros(NTail,1)  (bac.gxT'-major_axis)]';
    Mr(:,5)=[temp1(:);temp2(:)];
    %Z-direction velocity due to Y- and X-direction rotation
    temp1=[(bac.ryH') -(bac.rxH'-major_axis) zeros(Nhead,1)]';
    temp2=[bac.gyT' -(bac.gxT'-major_axis) zeros(NTail,1)]';
    Mr(:,6)=[temp1(:);temp2(:)];
    %Synthesizing the six-degree-of-freedom combined velocity matrix
    Mr=[Mr(1:3:3*(NALL),:);Mr(2:3:3*(NALL),:);Mr(3:3:3*(NALL),:)];

else %when there are no pilis

    Mb(1,:)=repmat([1 0 0],1,NALL);
    Mb(2,:)=repmat([0 1 0],1,NALL);
    Mb(3,:)=repmat([0 0 1],1,NALL);

    temp1=[zeros(Nhead,1) -(bac.gzH') (bac.gyH')]';
    Mb(4,:)=temp1(:)';

    temp1=[(bac.gzH') zeros(Nhead,1) -(bac.gxH'-major_axis)]';
    Mb(5,:)=temp1(:)';

    temp1=[-(bac.gyH') (bac.gxH'-major_axis) zeros(Nhead,1)]';
    Mb(6,:)=temp1(:)';

    Mb=[Mb(:,1:3:3*(NALL)) Mb(:,2:3:3*(NALL)) Mb(:,3:3:3*(NALL)) zeros(6,6)];

    Mr(:,1)=repmat([-1 0 0]',NALL,1);
    Mr(:,2)=repmat([0 -1 0]',NALL,1);
    Mr(:,3)=repmat([0 0 -1]',NALL,1);

    temp1=[zeros(Nhead,1) (bac.rzH') -(bac.ryH')]';
    Mr(:,4)=temp1(:);

    temp1=[-(bac.rzH') zeros(Nhead,1) (bac.rxH'-major_axis)]';
    Mr(:,5)=temp1(:);

    temp1=[(bac.ryH') -(bac.rxH'-major_axis) zeros(Nhead,1)]';
    Mr(:,6)=temp1(:);

    Mr=[Mr(1:3:3*(NALL),:);Mr(2:3:3*(NALL),:);Mr(3:3:3*(NALL),:)];

end

M=[Mall,Mr;Mb];

end