function FC = Ellipsoid_Friction_Coefficients(a, b, eta)
% Ellipsoid_Friction_Coefficients This function calculates the friction
% coefficients of a rotating ellipsoidal particles in a fluid with dynamic viscosity coefficient 'eta'.
%
% Inputs:
%   a - length of major axis
%   b - length of minor axis
%   eta - dynamic viscosity coefficient of the fluid
%
% Outputs:
%   f1, f2, f3 - translational friction coefficients
%   c1, c2, c3 - rotational friction coefficients


if a > b
    S = 2 / sqrt(a^2 - b^2) * log((a + sqrt(a^2 - b^2)) / b);
else
    S = 2 / sqrt(b^2 - a^2) * atan(sqrt(b^2 - a^2) / a);
end

f1 = 16 * pi * eta * (a^2 - b^2) / ((2*a^2 - b^2) * S - 2*a);
f2 = 32 * pi * eta * (a^2 - b^2) / ((2*a^2 - 3*b^2) * S + 2*a);
f3 = f2;

c1 = 32 * pi * eta * (a^2 - b^2)*b^2 / (3*(2*a - b^2*S));
c2 = 32 * pi * eta * (a^4 - b^4) / (3*((2*a^2 - b^2)*S - 2*a));
c3 = c2;

FC = [f1;f2;f3;c1;c2;c3];

end
