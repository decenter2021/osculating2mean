%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function OEMeanEUK2OEOsc
% Input: t_tdb: dynamic baricentric time since J2000 (s)
%        OEMean: mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%        degree: maximum degree of spherical harmonics geopotential model
% Output: mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%% Description
% 1. Computation of the J2-induced first second-order perturbations and the 
%    extraction of the J2-mean elements with Eckstein-Ustinov theory with 
%    method proposed in [1]
% 2. Computation of the geopotential perturbations with a spherical
%    harmonics geopotential model according to [2] and correction of the 
%    Eckstein-Ustinov mean orbital elements
% 3. Apply the perturbations to the mean orbital elements
% The code corrresponding to step 2. was adapted from an implementation by 
% Prof. Cheinway Hwang, made available in [3]

%% References
% [1] M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations
% due to any zonal and tesseral harmonics of the geopotential for 
% nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
% [2] Kaula, W.M., 2013. Theory of satellite geodesy: applications of 
% satellites to geodesy. Courier Corporation.
% [3] Hwang, C. and Hwang, L.S., 2002. Satellite orbit error due to 
% geopotential model error using perturbation theory: applications to 
% ROCSAT-2 and COSMIC missions. Computers & geosciences, 28(3), pp.357-367.
%% Implementation
function [OEosc] = OEMeanEUK2OEOsc(t_tdb,OEMean,degree) 
    % Perturbations of J2 first order 
    EUPerturbation  = EcksteinUstinovPerturbations(OEMean);
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
    % (Kaula excentricy correction has a singularity for near-circular orbits)
    OEosc  =  OEMean + [da; du; 0; 0; di; dOmega]; 
    OEosc(3:4) = OEMean(3:4) + EUPerturbation(3:4);
end
