%% ========================================================================
%  MILLER CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard, cold-air assumptions)
%
%  NOTE: the Miller cycle has several air-standard idealizations. This
%  model uses the over-expanded five-process form, where expansion runs
%  to a fixed expansion ratio e > r, then pressure drops at constant
%  volume to intake pressure, then exhaust at constant pressure:
%     1 -> 2 : Isentropic compression        (ratio r = V1/V2)
%     2 -> 3 : Constant-volume heat addition
%     3 -> 4 : Isentropic expansion           (to V4 = e*V2, e > r)
%     4 -> 5 : Constant-volume heat rejection  (P4 -> P1 at V4)
%     5 -> 1 : Constant-pressure heat rejection (V4 -> V1 at P1)
%
%  No single clean closed-form efficiency; computed from state points.
% ========================================================================

clear; clc; close all;

%% SECTION 1: WORKING FLUID PROPERTIES
R     = 287; gamma = 1.4; cv = R/(gamma-1); cp = gamma*cv;
fprintf('==================================================\n');
fprintf('  WORKING FLUID PROPERTIES (air, ideal gas)\n');
fprintf('==================================================\n');
fprintf('  Gas constant R        = %8.3f J/(kg*K)\n', R);
fprintf('  Specific heat ratio   = %8.3f\n', gamma);
fprintf('  cv                    = %8.3f J/(kg*K)\n', cv);
fprintf('  cp                    = %8.3f J/(kg*K)\n', cp);
fprintf('\n');

%% SECTION 2: CYCLE INPUT PARAMETERS
m    = 1.0;      % mass                        [kg]
T1   = 300;      % state 1 temperature         [K]
P1   = 100e3;    % state 1 pressure            [Pa]
r    = 8.0;      % compression ratio V1/V2     [-]
e    = 12.0;     % expansion ratio V4/V2 (>r)  [-]
q_in = 800e3;    % specific heat added 2->3    [J/kg]
Q_in = m*q_in;
V1 = m*R*T1/P1; V2 = V1/r;
fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  State 1 temperature   = %8.3f K\n', T1);
fprintf('  State 1 pressure      = %8.3f kPa\n', P1/1000);
fprintf('  Compression ratio r   = %8.3f\n', r);
fprintf('  Expansion ratio e     = %8.3f\n', e);
fprintf('  Heat added q_in       = %8.3f kJ/kg\n', q_in/1000);
fprintf('\n');

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 5 -> 1)
% STATE 2: isentropic compression
T2 = T1*r^(gamma-1); P2 = P1*r^gamma;
% STATE 3: constant-volume heat addition
V3 = V2; T3 = T2 + Q_in/(m*cv); P3 = m*R*T3/V3;
% STATE 4: isentropic expansion to V4 = e*V2
V4 = e*V2; T4 = T3*(V3/V4)^(gamma-1); P4 = P3*(V3/V4)^gamma;
% STATE 5: constant-volume heat rejection down to P5 = P1
V5 = V4; P5 = P1; T5 = P5*V5/(m*R);
% 5 -> 1 closes at constant pressure P1 (requires V4 > V1, i.e. e > r)

P_states = [P1,P2,P3,P4,P5]; V_states = [V1,V2,V3,V4,V5];
T_states = [T1,T2,T3,T4,T5];
fprintf('==================================================\n');
fprintf('  STATE POINTS\n');
fprintf('==================================================\n');
fprintf('  State    P [kPa]     V [m^3]      T [K]\n');
fprintf('  --------------------------------------------\n');
for i = 1:5
    fprintf('    %d    %9.2f   %9.6f   %8.2f\n', ...
            i, P_states(i)/1000, V_states(i), T_states(i));
end
fprintf('\n');

%% SECTION 4: HEAT AND WORK PER PROCESS
Q_12=0;                 W_12=m*cv*(T1-T2);      % isentropic comp
W_23=0;                 Q_23=m*cv*(T3-T2);      % const-V heat in
Q_34=0;                 W_34=m*cv*(T3-T4);      % isentropic exp
W_45=0;                 Q_45=m*cv*(T5-T4);      % const-V heat out
Q_51=m*cp*(T1-T5);      W_51=m*R *(T1-T5);      % const-P heat out
Q_processes=[Q_12,Q_23,Q_34,Q_45,Q_51];
W_processes=[W_12,W_23,W_34,W_45,W_51];
labels={'1->2 isentropic comp','2->3 const-V heat in',...
        '3->4 isentropic exp','4->5 const-V heat out',...
        '5->1 const-P heat out'};
fprintf('==================================================\n');
fprintf('  HEAT AND WORK PER PROCESS\n');
fprintf('==================================================\n');
fprintf('  Process                    Q [kJ]      W [kJ]\n');
fprintf('  ------------------------------------------------\n');
for i=1:5
    fprintf('  %-22s  %9.3f   %9.3f\n', ...
            labels{i}, Q_processes(i)/1000, W_processes(i)/1000);
end
fprintf('\n');

%% SECTION 5: CYCLE TOTALS AND EFFICIENCY
Q_out = abs(Q_45) + abs(Q_51);
W_net = sum(W_processes);
eta_cycle = W_net/Q_23;
energy_balance = (Q_23 - Q_out) - W_net;
fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY\n');
fprintf('==================================================\n');
fprintf('  Heat added Q_in       = %9.3f kJ\n', Q_23/1000);
fprintf('  Heat rejected Q_out   = %9.3f kJ\n', Q_out/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Energy balance resid  = %9.3e kJ (should be ~0)\n', energy_balance/1000);
fprintf('\n');
if abs(energy_balance) < 1e-3
    fprintf('  CHECK PASSED: energy balance closes (Q_in - Q_out = W_net).\n');
else
    fprintf('  CHECK FAILED: energy balance does not close.\n');
end
fprintf('\n');

%% SECTION 6: SMOOTH PROCESS CURVES
N=100;
V_12=linspace(V1,V2,N); P_12=P1*(V1./V_12).^gamma;    % isentropic
P_23=linspace(P2,P3,N); V_23=V2*ones(1,N);            % const V
V_34=linspace(V3,V4,N); P_34=P3*(V3./V_34).^gamma;    % isentropic
P_45=linspace(P4,P5,N); V_45=V4*ones(1,N);            % const V
V_51=linspace(V5,V1,N); P_51=P1*ones(1,N);            % const P
V_curve=[V_12,V_23,V_34,V_45,V_51];
P_curve=[P_12,P_23,P_34,P_45,P_51];

%% SECTION 7: ENTROPY VALUES
s1=0; s2=s1;                       % 1->2 isentropic
s3=s2+cv*log(T3/T2);               % 2->3 const V
s4=s3;                             % 3->4 isentropic
s5=s4+cv*log(T5/T4);               % 4->5 const V
s_states=[s1,s2,s3,s4,s5];
T23=linspace(T2,T3,N); s23=s2+cv*log(T23/T2);
T45=linspace(T4,T5,N); s45=s4+cv*log(T45/T4);
T51=linspace(T5,T1,N); s51=s5+cp*log(T51/T5);
s_TS=[s1,s2,s23,s3,s4,s45,s5,s51,s1];
T_TS=[T1,T2,T23,T3,T4,T45,T5,T51,T1];

%% SECTION 8: PLOTTING
figure('Name','Miller Cycle P-V Diagram','Color','w');
plot(V_curve,P_curve/1000,'b-','LineWidth',2); hold on;
plot(V_states,P_states/1000,'ro','MarkerFaceColor','r','MarkerSize',8);
for i=1:5
    text(V_states(i),P_states(i)/1000,sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Volume V [m^3]'); ylabel('Pressure P [kPa]');
title('Miller Cycle: P-V Diagram'); grid on; hold off;

figure('Name','Miller Cycle T-S Diagram','Color','w');
plot(s_TS,T_TS,'r-','LineWidth',2); hold on;
plot(s_states,T_states,'bo','MarkerFaceColor','b','MarkerSize',8);
for i=1:5
    text(s_states(i),T_states(i),sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Entropy change s [J/(kg*K)]'); ylabel('Temperature T [K]');
title('Miller Cycle: T-S Diagram'); grid on; hold off;

fprintf('Plots generated. Miller cycle model complete.\n');
%% END OF MILLER CYCLE MODEL
