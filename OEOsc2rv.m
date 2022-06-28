%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function OEOsc2rv
% Input: OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
% Output: x: 6x1 position-velocity vector
% Adaptation of Algorithm RANDV in [1, pp. 151] for near-circular
% orbits.
%% References
% [1] Vallado, D.A., 1997. Fundamentals of astrodynamics and applications.
% McGraw-Hill.
%% Implementation
function [x] = OEOsc2rv(OE,MaxIt,epsl)
    %% Set default parameter if they were not set 
    if nargin < 2 || isempty(MaxIt)
        MaxIt = 100;
    end
    if nargin < 3 || isempty(epsl)
        epsl = 1e-5; % (m)
    end    
    %% Define constants
    mu = 3.986004418e14; %(m^3s^2)
    %% Compute r,v for circular inclined OE
    a = OE(1);
    u = OE(2);
    e = sqrt(OE(3)^2+OE(4)^2);
    i = OE(5);
    Omega = OE(6);
    p = a*(1-e^2);
    %% (Vallado,1997) Algorithm 6
    if e < 1e-5
        omega = 0;
        nu = u;
    else
        omega = atan2(OE(4),OE(3));
        M = u-omega;
        % Fix angle difference
        if M < -pi
            M = M + (floor(abs(M-pi)/(2*pi)))*2*pi;
        elseif M > pi
            M = M - floor((M+pi)/(2*pi))*2*pi;
        end
        E = KepEqtnE(M,e,MaxIt,epsl);
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

%% Function KepEqtnE
% Input: M: mean anomaly
%        e: eccentricity
%        epsl: tolerance 
% Output: E: eccentric anomaly
% Algorithm KepEqtnE in [1, pp. 232]
%% References
% [1] Vallado, D.A., 1997. Fundamentals of astrodynamics and applications.
% McGraw-Hill.
%% Implementation
function E = KepEqtnE(M,e,MaxIt,epsl)
    if (M > -pi && M < 0 ) || M > pi
        E_n1 = M-e;
    else
        E_n1 = M+e;
    end
    count = 0;
    while true
        E_n = E_n1;
        E_n1 = E_n + (M-E_n+e*sin(E_n))/(1-e*cos(E_n));
        if abs(E_n1-E_n) < epsl
            E = E_n1;
            break;
        end
        count = count +1;
        if count >= MaxIt
            E = E_n1;
            warning('Maximum number of iterations for KepEqtnE reached.');
            break;      
        end
    end
end
