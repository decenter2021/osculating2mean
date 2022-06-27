%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function rv2OEOsc
% Input: x: 6x1 position-velocity vector
% Output: OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
% Adaptation of Algorithm ELORB in [1, pp. 146-147] for near-circular
% orbits.
%% References
% [1] Vallado, D.A., 1997. Fundamentals of astrodynamics and applications.
% McGraw-Hill.
%% Implementation
function [OE] = rv2OEOsc(x)
    %% Input
    r0 = x(1:3);
    v0 = x(4:6);
    %% Define constants
    mu = 3.986004418e14; %(m^3s^2)
    %% Compute classical orbit elements 
    % a
    a = -(mu/2)/((norm(v0)^2)/2-mu/norm(r0));
    % Excentricity vector 
    e_vec = ((norm(v0)^2-mu/norm(r0))*r0-(r0'*v0)*v0)/mu;
    e = norm(e_vec);
    % Angular momentum vector
    h = cross(r0,v0);
    % Line of nodes unit vector
    n = cross([0;0;1],h);
    n = n/norm(n);
    n_cross_h = cross(h/norm(h),n);
    n_cross_h = n_cross_h/norm(n_cross_h);
    
    %% Compute OE
    if e < 1e3*eps
        omega = 0;
        nu = acos(n'*(r0/norm(r0)));
        if (r0/norm(r0))'*cross(h/norm(h),n) < 0 
            nu = 2*pi-nu;
        end
        E = 2*atan(sqrt((1-e)/(1+e))*tan(nu/2));
        M = E-e*sin(E);
        u = M+omega;
    else
        omega = acos(n'*(e_vec/e));
        if e_vec(3) < 0
            omega = 2*pi-omega;
        end    
        nu = acos((e_vec'/e)*(r0/norm(r0)));
        if r0'*v0 < 0
            nu = 2*pi-nu;
        end
        E = 2*atan(sqrt((1-e)/(1+e))*tan(nu/2));
        M = E-e*sin(E);
        u = M+omega;
    end
    
    if u>2*pi
        u = u-floor(u/(2*pi))*2*pi;
    elseif u<0
        u = u+ceil(-u/(2*pi))*2*pi;
    end
    
    ex = n'*e_vec;
    ey = n_cross_h'*e_vec;
    i = acos(h(3)/norm(h));
    Omega = acos(n(1));
    if n(2) < 0
        Omega = 2*pi-Omega;
    end
    if Omega>2*pi
        Omega = Omega-floor(Omega/(2*pi))*2*pi;
    elseif Omega<0
        Omega = Omega+ceil(-Omega/(2*pi))*2*pi;
    end
    
    %% Output vector
    OE = zeros(6,1);
    OE(1) = a; % semi-major axis
    OE(2) = u;% u = M+omega
    OE(3) = ex; % e*cos(w)
    OE(4) = ey; % e*sin(w)
    OE(5) = i; % i
    OE(6) = Omega; % Omega
    
end