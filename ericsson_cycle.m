%% ========================================================================
%  ERICSSON CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard assumptions)
%
%  Two isothermals and two isobars, with ideal regeneration. The two
%  constant-pressure legs exchange heat internally, so only the isothermal
%  legs trade heat with the surroundings. Four processes:
%     1 -> 2 : Isothermal expansion at T_hot      (heat added, external)
%     2 -> 3 : Isobaric cooling at P_low          (heat to regenerator)
%     3 -> 4 : Isothermal compression at T_cold   (heat rejected, external)
%     4 -> 1 : Isobaric heating at P_high         (heat from regenerator)
%
%  With perfect regeneration, eta = 1 - T_cold/T_hot = Carnot.
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
m=1.0; T_hot=800; T_cold=300; P_high=600e3; P_low=100e3;
fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  Hot temperature       = %8.3f K\n', T_hot);
fprintf('  Cold temperature      = %8.3f K\n', T_cold);
fprintf('  High pressure         = %8.3f kPa\n', P_high/1000);
fprintf('  Low pressure          = %8.3f kPa\n', P_low/1000);
fprintf('\n');

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
% STATE 1: hot isotherm at high pressure
T1=T_hot;  P1=P_high; V1=m*R*T1/P1;
% STATE 2: end of isothermal expansion at T_hot, now at low pressure
T2=T_hot;  P2=P_low;  V2=m*R*T2/P2;
% STATE 3: end of isobaric cooling at P_low, now at T_cold
T3=T_cold; P3=P_low;  V3=m*R*T3/P3;
% STATE 4: end of isothermal compression at T_cold, back to high pressure
T4=T_cold; P4=P_high; V4=m*R*T4/P4;

P_states=[P1,P2,P3,P4]; V_states=[V1,V2,V3,V4]; T_states=[T1,T2,T3,T4];
fprintf('==================================================\n');
fprintf('  STATE POINTS\n');
fprintf('==================================================\n');
fprintf('  State    P [kPa]     V [m^3]      T [K]\n');
fprintf('  --------------------------------------------\n');
for i=1:4
    fprintf('    %d    %9.2f   %9.6f   %8.2f\n', ...
            i, P_states(i)/1000, V_states(i), T_states(i));
end
fprintf('\n');

%% SECTION 4: HEAT AND WORK PER PROCESS
% 1->2 isothermal at T_hot: Q = W = m*R*T_hot*ln(V2/V1)
W_12=m*R*T_hot*log(V2/V1);  Q_12=W_12;
% 2->3 isobaric cooling: Q = m*cp*dT (to regenerator), W = m*R*dT
Q_23=m*cp*(T3-T2);          W_23=m*R*(T3-T2);
% 3->4 isothermal at T_cold
W_34=m*R*T_cold*log(V4/V3); Q_34=W_34;
% 4->1 isobaric heating: Q = m*cp*dT (from regenerator), W = m*R*dT
Q_41=m*cp*(T1-T4);          W_41=m*R*(T1-T4);

Q_processes=[Q_12,Q_23,Q_34,Q_41];
W_processes=[W_12,W_23,W_34,W_41];
labels={'1->2 iso-T expansion','2->3 isobaric cool (regen)',...
        '3->4 iso-T compression','4->1 isobaric heat (regen)'};
fprintf('==================================================\n');
fprintf('  HEAT AND WORK PER PROCESS\n');
fprintf('==================================================\n');
fprintf('  Process                      Q [kJ]      W [kJ]\n');
fprintf('  --------------------------------------------------\n');
for i=1:4
    fprintf('  %-24s  %9.3f   %9.3f\n', ...
            labels{i}, Q_processes(i)/1000, W_processes(i)/1000);
end
fprintf('\n');

%% SECTION 5: CYCLE TOTALS AND EFFICIENCY
% With ideal regeneration the isobaric legs cancel externally. External
% heat input is only the hot isothermal leg.
Q_regen=m*cp*(T_hot-T_cold);        % internally recycled each way
Q_in_ext=Q_12;                      % external heat added
Q_out_ext=abs(Q_34);                % external heat rejected
W_net=sum(W_processes);
eta_cycle=W_net/Q_in_ext;
eta_carnot=1-T_cold/T_hot;
fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY (ideal regeneration)\n');
fprintf('==================================================\n');
fprintf('  Regenerator duty      = %9.3f kJ (each isobaric leg)\n', Q_regen/1000);
fprintf('  External heat in      = %9.3f kJ\n', Q_in_ext/1000);
fprintf('  External heat out     = %9.3f kJ\n', Q_out_ext/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Carnot efficiency     = %9.4f  (%.2f%%)\n', eta_carnot, eta_carnot*100);
fprintf('\n');
if abs(eta_cycle-eta_carnot)<1e-6
    fprintf('  CHECK PASSED: regenerated Ericsson reaches Carnot efficiency.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match Carnot limit.\n');
end
fprintf('\n');

%% SECTION 6: SMOOTH PROCESS CURVES
N=100;
V_12=linspace(V1,V2,N); P_12=m*R*T_hot./V_12;        % isothermal
V_23=linspace(V2,V3,N); P_23=P_low*ones(1,N);        % isobaric
V_34=linspace(V3,V4,N); P_34=m*R*T_cold./V_34;       % isothermal
V_41=linspace(V4,V1,N); P_41=P_high*ones(1,N);       % isobaric
V_curve=[V_12,V_23,V_34,V_41]; P_curve=[P_12,P_23,P_34,P_41];

%% SECTION 7: ENTROPY VALUES
s1=0;
s2=s1+R*log(V2/V1);          % 1->2 isothermal
s3=s2+cp*log(T3/T2);         % 2->3 isobaric
s4=s3+R*log(V4/V3);          % 3->4 isothermal
s_states=[s1,s2,s3,s4];
T23=linspace(T2,T3,N); s23=s2+cp*log(T23/T2);
T41=linspace(T4,T1,N); s41=s4+cp*log(T41/T4);
s_TS=[s1,s2,s23,s3,s4,s41,s1];
T_TS=[T1,T2,T23,T3,T4,T41,T1];

%% SECTION 8: PLOTTING
figure('Name','Ericsson Cycle P-V Diagram','Color','w');
plot(V_curve,P_curve/1000,'b-','LineWidth',2); hold on;
plot(V_states,P_states/1000,'ro','MarkerFaceColor','r','MarkerSize',8);
for i=1:4
    text(V_states(i),P_states(i)/1000,sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Volume V [m^3]'); ylabel('Pressure P [kPa]');
title('Ericsson Cycle: P-V Diagram'); grid on; hold off;

figure('Name','Ericsson Cycle T-S Diagram','Color','w');
plot(s_TS,T_TS,'r-','LineWidth',2); hold on;
plot(s_states,T_states,'bo','MarkerFaceColor','b','MarkerSize',8);
for i=1:4
    text(s_states(i),T_states(i),sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Entropy change s [J/(kg*K)]'); ylabel('Temperature T [K]');
title('Ericsson Cycle: T-S Diagram'); grid on; hold off;

fprintf('Plots generated. Ericsson cycle model complete.\n');
%% END OF ERICSSON CYCLE MODEL
