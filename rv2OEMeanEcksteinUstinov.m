%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function rv2OEMeanEU
% Input: x: 6x1 position-velocity vector
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
function OEMean = rv2OEMeanEcksteinUstinov(x, MaxIt, epslPos, epslVel)
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
    % Compute osculating parameters
    OEosc = rv2OEOsculating(x);
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
        % Update
        OEoscIt = OEMean + EUPerturbation;
        OEMean = OEosc - EUPerturbation;   
        % Check stopping criterion
        xIt = OEOsculating2rv(OEoscIt);
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