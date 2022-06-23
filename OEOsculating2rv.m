% OE to r,v
function [x] = OEOsculating2rv(OE)
    %% Input/Output 
    % Cf. Vallado1997 pp. 146-147
    % Input: OE
    % Output: r0 (m) and v0 (m/s)
    %% Define constants
    mu = 3.986004418e14; %(m^3s^2)
    %% Compute r,v for circular inclined OE
    a = OE(1);
    u = OE(2);
    e = sqrt(OE(3)^2+OE(4)^2);
    i = OE(5);
    Omega = OE(6);
    p = a*(1-e^2);
    
    %% Vallado 1997 Algorithm 6.
    if e < 1e3*eps
        omega = 0;
        nu = u;
    else
        omega = atan2(OE(4),OE(3));
        M = u-omega;
        E = keplerEq(M,e,1e3*eps);
        nu = 2*atan(sqrt((1+e)/(1-e))*tan(E/2));
    end
    
    rPQW = [p*cos(nu)/(1+e*cos(nu)); p*sin(nu)/(1+e*cos(nu));0];
    vPQW = [-sqrt(mu/p)*sin(nu); sqrt(mu/p)*(e+cos(nu));0];
    T = zeros(3,3);
    T(1,1) = cos(Omega)*cos(omega)-sin(Omega)*sin(omega)*cos(i);
    T(1,2) = -cos(Omega)*sin(omega)-sin(Omega)*cos(omega)*cos(i);
    T(1,3) = sin(Omega)*sin(i);
    T(2,1) = sin(Omega)*cos(omega)+cos(Omega)*sin(omega)*cos(i);
    T(2,2) = -sin(Omega)*sin(omega)+cos(Omega)*cos(omega)*cos(i);
    T(2,3) = -cos(Omega)*sin(i);
    T(3,1) = sin(omega)*sin(i);
    T(3,2) = cos(omega)*sin(i);
    T(3,3) = cos(i);
    x = zeros(6,1);
    x(1:3) = T*rPQW;
    x(4:6) = T*vPQW;
end