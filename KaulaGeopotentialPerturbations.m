%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function KaulaGeopotentialPerturbations
% Input: t_tdb: dynamic baricentric time since J2000 (s)
%        mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%        degree: maximum degree of spherical harmonics geopotential model
% Output: dOE: da, de, di, dOmega, dw, dM (semi-major axis, excentricity,
% inclination, longitude of ascending node, argument of perigee, mean anomaly)
% Computation of the geopotential perturbations with a spherical harmonics
% geopotential model according to [1] 
%% References
% [1] Kaula, W.M., 2013. Theory of satellite geodesy: applications of 
% satellites to geodesy. Courier Corporation.
%% Implementation
function dOE = KaulaGeopotentialPerturbations(t_tdb,OEmean,degree)
    %% Input variables
    a = OEmean(1);
    u = OEmean(2);
    ex = OEmean(3);
    ey = OEmean(4);
    i = OEmean(5);
    Omega = OEmean(6);
    %% Compute mean anomaly, w, and e
    w = atan2(ey,ex);
    M = u-w;
    if M>2*pi
        M = M-floor(M/(2*pi))*2*pi;
    elseif M<0
        M = M+ceil(-M/(2*pi))*2*pi;
    end  
    e = sqrt(ex^2+ey^2);
    %% Convert t_tdb to mofified julian date 
    %t_tt = t_tdb; % terrestrial time since J2000 (s)
    t_mjd = t_tdb/86400 +  51544.5; % julian date    
    %% Compute Kaula geopotential perturbations 
    % Form input to FORTRAN
    input = [t_mjd;... % epoch (mjd)
             a; ... % a (m)
             M; ... % M (rad)
             u; ... % u (rad)
             e; ... % e
             i; ... % i (rad)
             Omega; ... % Omega (rad)
             degree]; % Max degree
    % Computation in FORTRAN mex
    dOE = KaulaGeopotentialPerturbations_mex(input);   
end

