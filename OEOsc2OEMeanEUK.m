%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function OEOsc2OEMeanEUK
% Input: t_tdb: dynamic baricentric time since J2000 (s)
%        OEOsc: osculating OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%        degree: maximum degree of spherical harmonics geopotential model
% Output: mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%% Description
% Main steps inspired by the approach in [1]:
% 1. Iterative computation of the J2-induced first second-order 
%    perturbations and the extraction of the J2-mean elements with 
%    Eckstein-Ustinov theory with method proposed in [2]
% 2. Computation of the geopotential perturbations with a spherical
%    harmonics geopotential model according to [3] and correction of the 
%    Eckstein-Ustinov mean orbital elements
% The code corrresponding to step 2. was adapted from an implementation by 
% Prof. Cheinway Hwang, made available in [4]

%% References
% [1] Spiridonova, S., Kirschner, M. and Hugentobler, U., 2014. Precise 
% mean orbital elements determination for LEO monitoring and maintenance.
% [2] M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations
% due to any zonal and tesseral harmonics of the geopotential for 
% nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
% [3] Kaula, W.M., 2013. Theory of satellite geodesy: applications of 
% satellites to geodesy. Courier Corporation.
% [4] Hwang, C. and Hwang, L.S., 2002. Satellite orbit error due to 
% geopotential model error using perturbation theory: applications to 
% ROCSAT-2 and COSMIC missions. Computers & geosciences, 28(3), pp.357-367.
%% Implementation

function [OEMean] = OEOsc2OEMeanEUK(t_tdb,OEosc,degree)
    % Iterative computation of the J2-induced first second-order 
    % perturbations and the extraction of the J2-mean elements with 
    % Eckstein-Ustinov theory with method proposed in [1]
    OEMean_EU = OEOsc2OEMeanEU(OEosc);
    % Compute geopotentential perturbations
    dOE = KaulaGeopotentialPerturbations(t_tdb,OEMean_EU,degree);
    da = dOE(1);
    de = dOE(2);
    di = dOE(3);
    dOmega = dOE(4);
    dw = dOE(5);
    dM = dOE(6);
    % Compute perturbations for circular coordinates    
    du = dM+dw;
    % Correct EU mean elements 
    % (excentricy correction has a singularity for near-circular orbits)
    OEMean = OEosc - [da; du; 0; 0; di; dOmega]; 
    OEMean(3:4) = OEMean_EU(3:4);
    % Fix angle ranges
    if OEMean(2)>2*pi
        OEMean(2) = OEMean(2)-floor(OEMean(2)/(2*pi))*2*pi;
    elseif OEMean(2)<0
        OEMean(2) = OEMean(2)+ceil(-OEMean(2)/(2*pi))*2*pi;
    end
    if OEMean(6)>2*pi
        OEMean(6) = OEMean(6)-floor(OEMean(6)/(2*pi))*2*pi;
    elseif OEMean(6)<0
        OEMean(6) = OEMean(6)+ceil(-OEMean(6)/(2*pi))*2*pi;
    end
end
