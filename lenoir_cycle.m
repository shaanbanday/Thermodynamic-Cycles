%% ========================================================================
%  LENOIR CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard assumptions)
%
%  Pulse-jet / early internal combustion cycle, no compression stroke.
%  Three processes:
%     1 -> 2 : Constant-volume heat addition
%     2 -> 3 : Isentropic expansion down to P3 = P1
%     3 -> 1 : Constant-pressure heat rejection
%
%  eta = 1 - gamma*(beta^(1/gamma) - 1)/(beta - 1),  beta = P2/P1
% ========================================================================

clear; clc; close all;

%% SECTION 1: WORKING FLUID PROPERTIES
R=287; gamma=1.4; cv=R/(gamma-1); cp=gamma*cv;
fprintf('==================================================\n');
fprintf('  WORKING FLUID PROPERTIES (air, ideal gas)\n');
fprintf('==================================================\n');
fprintf('  Gas constant R        = %8.3f J/(kg*K)\n', R);
fprintf('  Specific heat ratio   = %8.3f\n', gamma);
fprintf('  cv                    = %8.3f J/(kg*K)\n', cv);
fprintf('  cp                    = %8.3f J/(kg*K)\n', cp);
fprintf('\n');

%% SECTION 2: CYCLE INPUT PARAMETERS
m=1.0; T1=300; P1=100e3; q_in=800e3; Q_in=m*q_in;
V1=m*R*T1/P1;
fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  State 1 temperature   = %8.3f K\n', T1);
fprintf('  State 1 pressure      = %8.3f kPa\n', P1/1000);
fprintf('  Heat added q_in       = %8.3f kJ/kg\n', q_in/1000);
fprintf('  Volume at state 1     = %8.6f m^3\n', V1);
fprintf('\n');

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 1)
% STATE 2: constant-volume heat addition
V2=V1; T2=T1+Q_in/(m*cv); P2=P1*T2/T1;
beta=P2/P1;                         % pressure ratio
% STATE 3: isentropic expansion to P3 = P1
P3=P1; T3=T2*(P3/P2)^((gamma-1)/gamma); V3=m*R*T3/P3;

P_states=[P1,P2,P3]; V_states=[V1,V2,V3]; T_states=[T1,T2,T3];
fprintf('==================================================\n');
fprintf('  STATE POINTS  (beta = P2/P1 = %6.4f)\n', beta);
fprintf('==================================================\n');
fprintf('  State    P [kPa]     V [m^3]      T [K]\n');
fprintf('  --------------------------------------------\n');
for i=1:3
    fprintf('    %d    %9.2f   %9.6f   %8.2f\n', ...
            i, P_states(i)/1000, V_states(i), T_states(i));
end
fprintf('\n');

%% SECTION 4: HEAT AND WORK PER PROCESS
W_12=0;            Q_12=m*cv*(T2-T1);     % const-V heat in
Q_23=0;            W_23=m*cv*(T2-T3);     % isentropic expansion
Q_31=m*cp*(T1-T3); W_31=m*R *(T1-T3);     % const-P heat out
Q_processes=[Q_12,Q_23,Q_31];
W_processes=[W_12,W_23,W_31];
labels={'1->2 const-V heat in','2->3 isentropic exp','3->1 const-P heat out'};
fprintf('==================================================\n');
fprintf('  HEAT AND WORK PER PROCESS\n');
fprintf('==================================================\n');
fprintf('  Process                    Q [kJ]      W [kJ]\n');
fprintf('  ------------------------------------------------\n');
for i=1:3
    fprintf('  %-22s  %9.3f   %9.3f\n', ...
            labels{i}, Q_processes(i)/1000, W_processes(i)/1000);
end
fprintf('\n');

%% SECTION 5: CYCLE TOTALS AND EFFICIENCY
Q_out=abs(Q_31); W_net=sum(W_processes);
eta_cycle=W_net/Q_12;
eta_ideal=1-gamma*(beta^(1/gamma)-1)/(beta-1);
energy_balance=(Q_12-Q_out)-W_net;
fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY\n');
fprintf('==================================================\n');
fprintf('  Heat added Q_in       = %9.3f kJ\n', Q_12/1000);
fprintf('  Heat rejected Q_out   = %9.3f kJ\n', Q_out/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Ideal Lenoir eff.     = %9.4f  (%.2f%%)\n', eta_ideal, eta_ideal*100);
fprintf('  Energy balance resid  = %9.3e kJ (should be ~0)\n', energy_balance/1000);
fprintf('\n');
if abs(eta_cycle-eta_ideal)<1e-6
    fprintf('  CHECK PASSED: efficiency matches air-standard Lenoir formula.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match formula.\n');
end
fprintf('\n');

%% SECTION 6: SMOOTH PROCESS CURVES
N=100;
P_12=linspace(P1,P2,N); V_12=V1*ones(1,N);           % const V
V_23=linspace(V2,V3,N); P_23=P2*(V2./V_23).^gamma;   % isentropic
V_31=linspace(V3,V1,N); P_31=P1*ones(1,N);           % const P
V_curve=[V_12,V_23,V_31]; P_curve=[P_12,P_23,P_31];

%% SECTION 7: ENTROPY VALUES
s1=0; s2=s1+cv*log(T2/T1); s3=s2;    % 1->2 const V, 2->3 isentropic
s_states=[s1,s2,s3];
T12=linspace(T1,T2,N); s12=s1+cv*log(T12/T1);
T31=linspace(T3,T1,N); s31=s3+cp*log(T31/T3);
s_TS=[s1,s12,s2,s3,s31,s1];
T_TS=[T1,T12,T2,T3,T31,T1];

%% SECTION 8: PLOTTING
figure('Name','Lenoir Cycle P-V Diagram','Color','w');
plot(V_curve,P_curve/1000,'b-','LineWidth',2); hold on;
plot(V_states,P_states/1000,'ro','MarkerFaceColor','r','MarkerSize',8);
for i=1:3
    text(V_states(i),P_states(i)/1000,sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Volume V [m^3]'); ylabel('Pressure P [kPa]');
title('Lenoir Cycle: P-V Diagram'); grid on; hold off;

figure('Name','Lenoir Cycle T-S Diagram','Color','w');
plot(s_TS,T_TS,'r-','LineWidth',2); hold on;
plot(s_states,T_states,'bo','MarkerFaceColor','b','MarkerSize',8);
for i=1:3
    text(s_states(i),T_states(i),sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Entropy change s [J/(kg*K)]'); ylabel('Temperature T [K]');
title('Lenoir Cycle: T-S Diagram'); grid on; hold off;

fprintf('Plots generated. Lenoir cycle model complete.\n');
%% END OF LENOIR CYCLE MODEL
