%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function OEOsc2OEMeanEU
% Input: osculating OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
% Output: mean OE: a, u (mean anomaly + arg perigee), ex, ey, i, longitude of asceding node
%% Description
% Main steps:
% 1.    Iterative computation of the J2-induced first second-order 
%       perturbations and the extraction of the J2-mean elements with 
%       Eckstein-Ustinov theory with method proposed in [1]
% 1.1.  Initilization: Mean elements are equal to osculating elements
% 1.2.  Iterate the Eckstein-Ustinov corrections
% 1.3.  Stop when the position-vector obtained with the oscullating
% elements that resulted from the iteration is close enough to the original
% position-vector
%% References
% [1] M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations
% due to any zonal and tesseral harmonics of the geopotential for 
% nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
%% Implementation
function OEMean = OEOsc2OEMeanEU(OEosc, MaxIt, epslPos, epslVel)
    % Set default parameter if they were not set 
    if nargin < 2 || isempty(MaxIt)
        MaxIt = 100;
    end
    if nargin < 3 || isempty(epslPos)
        epslPos = 1e-1; % (m)
    end
    if nargin < 4 || isempty(epslVel)
        epslVel = 1e-4; % (m/s)
    end
    % Compute position-velocity vector
    x = OEOsc2rv(OEosc);
    % 1. Iterative computation of the J2-induced first second-order 
    %    perturbations and the extraction of the J2-mean elements with 
    %    Eckstein-Ustinov theory with method proposed in [2]
    % 1.1 Initilization: Mean elements are equal to osculating elements 
    OEMean = OEosc;
    % 1.2 Iterate the Eckstein-Ustinov corrections
    status = zeros(2,MaxIt);
    for i = 1:MaxIt
        % Compute perturbation
        EUPerturbation  = EcksteinUstinovPerturbations(OEMean);
        % Update and fix angle ranges
        OEoscIt = OEMean + EUPerturbation;
        if OEoscIt(2)>2*pi
            OEoscIt(2) = OEoscIt(2)-floor(OEoscIt(2)/(2*pi))*2*pi;
        elseif OEoscIt(2)<0
            OEoscIt(2) = OEoscIt(2)+ceil(-OEoscIt(2)/(2*pi))*2*pi;
        end
        if OEoscIt(6)>2*pi
            OEoscIt(6) = OEoscIt(6)-floor(OEoscIt(6)/(2*pi))*2*pi;
        elseif OEoscIt(6)<0
            OEoscIt(6) = OEoscIt(6)+ceil(-OEoscIt(6)/(2*pi))*2*pi;
        end
        % Update and fix angle ranges
        OEMean = OEosc - EUPerturbation;   
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

        % Check stopping criterion
        xIt = OEOsc2rv(OEoscIt);
        status(1,i) = norm(xIt(1:3)-x(1:3));
        status(2,i) = norm(xIt(4:6)-x(4:6));
        if norm(xIt(1:3)-x(1:3)) < epslPos && norm(xIt(4:6)-x(4:6)) < epslVel
            break;
        end
        if i == MaxIt
            error('Maximum number of iterations reached for rv2OEMeanEcksteinUstinov.');
        end
    end     
end