%% ========================================================================
%  STIRLING CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard assumptions)
%
%  Two isothermals and two isochorics, with ideal regeneration. The two
%  constant-volume legs exchange heat internally. Four processes:
%     1 -> 2 : Isothermal expansion at T_hot      (heat added, external)
%     2 -> 3 : Isochoric cooling                  (heat to regenerator)
%     3 -> 4 : Isothermal compression at T_cold   (heat rejected, external)
%     4 -> 1 : Isochoric heating                  (heat from regenerator)
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
m=1.0; T_hot=800; T_cold=300; P1=600e3; rv=2.0;   % rv = V2/V1 volume ratio
V1=m*R*T_hot/P1; V2=rv*V1;
fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  Hot temperature       = %8.3f K\n', T_hot);
fprintf('  Cold temperature      = %8.3f K\n', T_cold);
fprintf('  State 1 pressure      = %8.3f kPa\n', P1/1000);
fprintf('  Volume ratio V2/V1    = %8.3f\n', rv);
fprintf('\n');

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
% STATE 1: hot isotherm, minimum volume
T1=T_hot;  V1_=V1; P1_=P1;
% STATE 2: isothermal expansion at T_hot to V2
T2=T_hot;  V2_=V2; P2=m*R*T2/V2;
% STATE 3: isochoric cooling at V2 to T_cold
T3=T_cold; V3=V2;  P3=m*R*T3/V3;
% STATE 4: isothermal compression at T_cold back to V1
T4=T_cold; V4=V1;  P4=m*R*T4/V4;

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
% 2->3 isochoric cooling: W = 0, Q = m*cv*dT (to regenerator)
W_23=0;                     Q_23=m*cv*(T3-T2);
% 3->4 isothermal at T_cold
W_34=m*R*T_cold*log(V4/V3); Q_34=W_34;
% 4->1 isochoric heating: W = 0, Q = m*cv*dT (from regenerator)
W_41=0;                     Q_41=m*cv*(T1-T4);

Q_processes=[Q_12,Q_23,Q_34,Q_41];
W_processes=[W_12,W_23,W_34,W_41];
labels={'1->2 iso-T expansion','2->3 isochoric cool (regen)',...
        '3->4 iso-T compression','4->1 isochoric heat (regen)'};
fprintf('==================================================\n');
fprintf('  HEAT AND WORK PER PROCESS\n');
fprintf('==================================================\n');
fprintf('  Process                       Q [kJ]      W [kJ]\n');
fprintf('  ---------------------------------------------------\n');
for i=1:4
    fprintf('  %-25s  %9.3f   %9.3f\n', ...
            labels{i}, Q_processes(i)/1000, W_processes(i)/1000);
end
fprintf('\n');

%% SECTION 5: CYCLE TOTALS AND EFFICIENCY
Q_regen=m*cv*(T_hot-T_cold);
Q_in_ext=Q_12; Q_out_ext=abs(Q_34);
W_net=sum(W_processes);
eta_cycle=W_net/Q_in_ext;
eta_carnot=1-T_cold/T_hot;
fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY (ideal regeneration)\n');
fprintf('==================================================\n');
fprintf('  Regenerator duty      = %9.3f kJ (each isochoric leg)\n', Q_regen/1000);
fprintf('  External heat in      = %9.3f kJ\n', Q_in_ext/1000);
fprintf('  External heat out     = %9.3f kJ\n', Q_out_ext/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Carnot efficiency     = %9.4f  (%.2f%%)\n', eta_carnot, eta_carnot*100);
fprintf('\n');
if abs(eta_cycle-eta_carnot)<1e-6
    fprintf('  CHECK PASSED: regenerated Stirling reaches Carnot efficiency.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match Carnot limit.\n');
end
fprintf('\n');

%% SECTION 6: SMOOTH PROCESS CURVES
N=100;
V_12=linspace(V1,V2,N); P_12=m*R*T_hot./V_12;        % isothermal
P_23=linspace(P2,P3,N); V_23=V2*ones(1,N);           % isochoric
V_34=linspace(V3,V4,N); P_34=m*R*T_cold./V_34;       % isothermal
P_41=linspace(P4,P1,N); V_41=V1*ones(1,N);           % isochoric
V_curve=[V_12,V_23,V_34,V_41]; P_curve=[P_12,P_23,P_34,P_41];

%% SECTION 7: ENTROPY VALUES
s1=0;
s2=s1+R*log(V2/V1);          % 1->2 isothermal
s3=s2+cv*log(T3/T2);         % 2->3 isochoric
s4=s3+R*log(V4/V3);          % 3->4 isothermal
s_states=[s1,s2,s3,s4];
T23=linspace(T2,T3,N); s23=s2+cv*log(T23/T2);
T41=linspace(T4,T1,N); s41=s4+cv*log(T41/T4);
s_TS=[s1,s2,s23,s3,s4,s41,s1];
T_TS=[T1,T2,T23,T3,T4,T41,T1];

%% SECTION 8: PLOTTING
figure('Name','Stirling Cycle P-V Diagram','Color','w');
plot(V_curve,P_curve/1000,'b-','LineWidth',2); hold on;
plot(V_states,P_states/1000,'ro','MarkerFaceColor','r','MarkerSize',8);
for i=1:4
    text(V_states(i),P_states(i)/1000,sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Volume V [m^3]'); ylabel('Pressure P [kPa]');
title('Stirling Cycle: P-V Diagram'); grid on; hold off;

figure('Name','Stirling Cycle T-S Diagram','Color','w');
plot(s_TS,T_TS,'r-','LineWidth',2); hold on;
plot(s_states,T_states,'bo','MarkerFaceColor','b','MarkerSize',8);
for i=1:4
    text(s_states(i),T_states(i),sprintf('  %d',i),...
         'FontSize',12,'FontWeight','bold');
end
xlabel('Entropy change s [J/(kg*K)]'); ylabel('Temperature T [K]');
title('Stirling Cycle: T-S Diagram'); grid on; hold off;

fprintf('Plots generated. Stirling cycle model complete.\n');
%% END OF STIRLING CYCLE MODEL
