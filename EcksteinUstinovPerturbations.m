%% Package: osculating2mean
% Author: Leonardo Pedroso
%% Function EcksteinUstinovPerturbations
% Computation of the Eckstein-Ustinov perturbations according to [1]. 
% Non-singular orbital elements are employed: 
% a: semi-major axis
% lambda: mean anomaly + argument of perigee
% ex: e*cos(argument of perigee)
% ey: e*sin(argument of perigee)
% i: inclination
% Omega: longitude of ascending node
% Imputs: 6x1 vector of non-singular orbital elements in the order above
% Output: 6x1 vector of Eckstein-Ustinov perturbations for the non-singular
%           orbital elements in the order above
%% References
% [1] M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations
% due to any zonal and tesseral harmonics of the geopotential for 
% nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
%% Implementation
function EUPerturbations =  EcksteinUstinovPerturbations(OEMean)
    % Constants
    mu = 3.986004418e14; %(m^3 s^-2)
    RE = 6378.137e3; %(m)
    J2 = 1082.6267e-6;
    % Process input parameters (using the notation of [1])
    a0 = OEMean(1);
    i0 = OEMean(5);
    e0 = sqrt(OEMean(3)^2+OEMean(4)^2);
    l0 = OEMean(3); % ex
    h0 = OEMean(4); % ey
    lambda_0 = OEMean(2);
    Omega_0 = OEMean(6);
    % Compute parameters
    G2 = -J2*(RE/a0)^2;
    beta_0 = sin(i0);
    lambda_star = 1-(3/2)*G2*(3-4*beta_0);
    xi_0 = cos(i0);
    % Compute Eckstein-Ustinov perturbations
    da = -(3/2)*(a0/lambda_star)*G2*((2-(7/2)*beta_0^2)*l0*cos(lambda_0)+...
    (2-(5/2)*beta_0^2)*h0*sin(lambda_0)+ beta_0^2*cos(2*lambda_0)+...
    (7/2)*beta_0^2*(l0*cos(3*lambda_0)+h0*sin(3*lambda_0)))+...
    (3/4)*a0*G2^2*beta_0^2*(7*(2-3*beta_0^2)*cos(2*lambda_0)+...
    beta_0^2*cos(4*lambda_0));
    dh = -(3/(2*lambda_star))*G2*((1-(7/4)*beta_0^2)*sin(lambda_0)+...
        (1-3*beta_0^2)*l0*sin(2*lambda_0)+...
        (-(3/2)+2*beta_0^2)*h0*cos(2*lambda_0)+...
        (7/12)*beta_0^2*sin(3*lambda_0)+...
        (17/8)*beta_0^2*(l0*sin(4*lambda_0)-h0*cos(4*lambda_0)));
    dl = -(3/(2*lambda_star))*G2*((1-(5/4)*beta_0^2)*cos(lambda_0)+...
        (1/2)*(3-5*beta_0^2)*l0*cos(2*lambda_0)+...
        (2-(3/2)*beta_0^2)*h0*sin(2*lambda_0)+...
        (7/12)*beta_0^2*cos(3*lambda_0)+...
        (17/8)*beta_0^2*(l0*cos(4*lambda_0)+h0*sin(4*lambda_0)));
    di = -(3/(4*lambda_star))*G2*beta_0*xi_0*(-l0*cos(lambda_0)+...
        h0*sin(lambda_0)+cos(2*lambda_0)+(7/3)*l0*cos(3*lambda_0)+...
        (7/3)*h0*sin(3*lambda_0));
    dOmega = (3/(2*lambda_star))*G2*xi_0*((7/2)*l0*sin(lambda_0)-...
        (5/2)*h0*cos(lambda_0)-(1/2)*sin(2*lambda_0)-...
        (7/6)*l0*sin(3*lambda_0)+(7/6)*h0*cos(3*lambda_0));
    dlambda = -(3/(2*lambda_star))*G2*((10-(119/8)*beta_0^2)*l0*sin(lambda_0)+...
        ((85/8)*beta_0^2-9)*h0*cos(lambda_0)+...
        (2*beta_0^2-(1/2))*sin(2*lambda_0)+...
        (-(7/6)+(119/24)*beta_0^2)*(l0*sin(3*lambda_0)-h0*cos(3*lambda_0))-...
        (3-(21/4)*beta_0^2)*l0*sin(lambda_0)+...
        (3-(15/4)*beta_0^2)*h0*cos(lambda_0)-...
        (3/4)*beta_0^2*sin(2*lambda_0)-...
        (21/12)*beta_0^2*(l0*sin(3*lambda_0)-h0*cos(3*lambda_0)));
    % Output
    EUPerturbations = zeros(6,1);
    EUPerturbations(1) = da; % a
    EUPerturbations(2) = dlambda; 
    EUPerturbations(3) = dl; %ex
    EUPerturbations(4) = dh; % ey
    EUPerturbations(5) = di; % i
    EUPerturbations(6) = dOmega; % Omega
end
