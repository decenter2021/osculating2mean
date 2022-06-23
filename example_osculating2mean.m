%% Example osculating2mean

%% Load osculating position timeseries
% Time-series of roughly 10 orbits of a satelite in LEO with atmospheric
% drag; cannon ball solar radiation pressure; third body perturbations from
% the Sun, Moon, Mars, Venus; spherical harmonic gravity of degree and
% order 12
load('./data/output.mat','x');
Ts = 10; %(s)

% Compute osculating orbital elements 
OE_osc = zeros(6,size(x,2));
for t = 1:size(x,2)
    OE_osc(:,t) = rv2OEOsculating(x(:,t));
end

% Compute mean orbital elements 
OE_mean_EcksteinUstinov = zeros(6,size(x,2));
OE_mean_EcksteinUstinovKaula = zeros(6,size(x,2));
degree = 10;
for t = 1:size(x,2)
    OE_mean_EcksteinUstinov(:,t) = rv2OEMeanEcksteinUstinov(x(:,t));
    OE_mean_EcksteinUstinovKaula(:,t) = rv2OEMeanEcksteinUstinovKaula((t-1)*Ts,x(:,t),degree);
end

%% Plot results
% Constants
mu = 3.986004418e14; %(m^3 s^-2)
RE = 6378.137e3; %(m)
J2 = 1082.6267e-6;
% Compute parameters
semiMajorAxis = mean(OE_osc(1,:));
incl = mean(OE_osc(5,:));
n = sqrt(mu/(semiMajorAxis)^3);
gamma = (J2/2)*(RE/semiMajorAxis)^2;
Omega_dot = -3*gamma*n*cos(incl);
arg_perigee_dot = (3/2)*gamma*n*(5*cos(incl)^2-1);
M_dot = (3/2)*gamma*n*(3*cos(incl)^2-1);
u_dot = n + M_dot + arg_perigee_dot;

T = size(x,2);

figure;
hold on
ylabel('$a$ (m)','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,OE_osc(1,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinov(1,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinovKaula(1,1:T));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

figure;
hold on
ylabel('$a$ (m)','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,OE_osc(1,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinov(1,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinovKaula(1,1:T));
ylim([min(OE_mean_EcksteinUstinov(1,1:T)) max(OE_mean_EcksteinUstinov(1,1:T))])
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

aux = zeros(3,T);
aux(1,:) = OE_osc(2,:)-u_dot*(0:1:T-1)*Ts;
aux(2,:) = OE_mean_EcksteinUstinov(2,:)-u_dot*(0:1:T-1)*Ts;
aux(3,:) = OE_mean_EcksteinUstinovKaula(2,:)-u_dot*(0:1:T-1)*Ts;
aux(aux < -pi) = aux(aux <- pi) - 2*pi*floor((aux(aux <- pi)+pi)/(2*pi));
figure;
hold on
ylabel('$u-\dot{u}t$ (rad)','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,aux(1,:));
plot(0:Ts:(T-1)*Ts,aux(2,:));
plot(0:Ts:(T-1)*Ts,aux(3,:));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

figure;
hold on
ylabel('$e_x$','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,OE_osc(3,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinov(3,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinovKaula(3,1:T));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

figure;
hold on
ylabel('$e_y$','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,OE_osc(4,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinov(4,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinovKaula(4,1:T));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

figure;
hold on
ylabel('$i$ (rad)','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,OE_osc(5,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinov(5,1:T));
plot(0:Ts:(T-1)*Ts,OE_mean_EcksteinUstinovKaula(5,1:T));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');

aux = zeros(3,T);
aux(1,:) = OE_osc(6,1:T)-Omega_dot*(0:1:T-1)*Ts;
aux(2,:) = OE_mean_EcksteinUstinov(6,1:T)-Omega_dot*(0:1:T-1)*Ts;
aux(3,:) = OE_mean_EcksteinUstinovKaula(6,1:T)-Omega_dot*(0:1:T-1)*Ts;
aux(aux > pi) = aux(aux > pi) - 2*pi*floor((aux(aux > pi)+pi)/(2*pi));
figure;
hold on
ylabel('$\Omega-\dot{\Omega}t$ (rad)','Interpreter','latex')
xlabel('$t$ (s)','Interpreter','latex')
plot(0:Ts:(T-1)*Ts,aux(1,:));
plot(0:Ts:(T-1)*Ts,aux(2,:));
plot(0:Ts:(T-1)*Ts,aux(3,:));
legend('Osculating','EcksteinUstinov','EcksteinUstinovKaula');


