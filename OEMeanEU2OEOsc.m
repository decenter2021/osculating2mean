%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function OEMeanEU2OEOsc
% Output: mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
% Input: osculating OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%% Description
% Computation of the J2-induced first second-order perturbations and the 
% extraction of the J2-mean elements with Eckstein-Ustinov theory with 
% method proposed in [1]
%% References
% [1] M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations
% due to any zonal and tesseral harmonics of the geopotential for 
% nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
%% Implementation
function OEosc = OEMeanEU2OEOsc(OEMean)
    % Compute perturbation
    EUPerturbation  = EcksteinUstinovPerturbations(OEMean);
    % Update
    OEosc = OEMean + EUPerturbation;
    % Fix angles
    if OEosc(2)>2*pi
        OEosc(2) = OEosc(2)-floor(OEosc(2)/(2*pi))*2*pi;
    elseif OEosc(2)<0
        OEosc(2) = OEosc(2)+ceil(-OEosc(2)/(2*pi))*2*pi;
    end
    if OEosc(6)>2*pi
        OEosc(6) = OEosc(6)-floor(OEosc(6)/(2*pi))*2*pi;
    elseif OEosc(6)<0
        OEosc(6) = OEosc(6)+ceil(-OEosc(6)/(2*pi))*2*pi;
    end
end