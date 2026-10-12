%% ========================================================================
%  DIESEL CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard, cold-air assumptions)
%
%  Compression-ignition engine idealization. Four processes:
%     1 -> 2 : Isentropic compression
%     2 -> 3 : Constant-pressure heat addition (fuel burns as it injects)
%     3 -> 4 : Isentropic expansion
%     4 -> 1 : Constant-volume heat rejection
%
%  eta = 1 - (1/r^(gamma-1)) * (rc^gamma - 1)/(gamma*(rc - 1))
%  where r = compression ratio, rc = cutoff ratio V3/V2
% ========================================================================

clear;
clc;
close all;

%% ------------------------------------------------------------------------
%  SECTION 1: WORKING FLUID PROPERTIES (AIR, IDEAL GAS)
% ------------------------------------------------------------------------

R     = 287;                % specific gas constant for air   [J/(kg*K)]
gamma = 1.4;                % ratio of specific heats          [-]
cv    = R / (gamma - 1);    % constant-volume specific heat    [J/(kg*K)]
cp    = gamma * cv;         % constant-pressure specific heat  [J/(kg*K)]

fprintf('==================================================\n');
fprintf('  WORKING FLUID PROPERTIES (air, ideal gas)\n');
fprintf('==================================================\n');
fprintf('  Gas constant R        = %8.3f J/(kg*K)\n', R);
fprintf('  Specific heat ratio   = %8.3f\n', gamma);
fprintf('  cv                    = %8.3f J/(kg*K)\n', cv);
fprintf('  cp                    = %8.3f J/(kg*K)\n', cp);
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 2: CYCLE INPUT PARAMETERS
% ------------------------------------------------------------------------

m     = 1.0;                % mass of working fluid            [kg]
T1    = 300;                % temperature at state 1 (BDC)     [K]
P1    = 100e3;              % pressure at state 1              [Pa]
r     = 18.0;               % compression ratio V1/V2          [-]
q_in  = 900e3;              % specific heat added, 2->3        [J/kg]
Q_in  = m * q_in;           % total heat added                 [J]

V1    = m * R * T1 / P1;    % volume at state 1                [m^3]
V2    = V1 / r;             % volume after compression         [m^3]

fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  State 1 temperature   = %8.3f K\n', T1);
fprintf('  State 1 pressure      = %8.3f kPa\n', P1/1000);
fprintf('  Compression ratio r   = %8.3f\n', r);
fprintf('  Heat added q_in       = %8.3f kJ/kg\n', q_in/1000);
fprintf('  Volume at state 1     = %8.6f m^3\n', V1);
fprintf('  Volume at state 2     = %8.6f m^3\n', V2);
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
% ------------------------------------------------------------------------

% ----- STATE 2: end of isentropic compression (1 -> 2) -----
T2 = T1 * r^(gamma - 1);
P2 = P1 * r^gamma;

% ----- STATE 3: end of constant-pressure heat addition (2 -> 3) -----
P3 = P2;                        % pressure held constant
T3 = T2 + Q_in / (m * cp);      % heat added at constant pressure
V3 = m * R * T3 / P3;           % volume grows as gas expands
rc = V3 / V2;                   % cutoff ratio

% ----- STATE 4: end of isentropic expansion (3 -> 4) -----
V4 = V1;                        % expands back to BDC volume
T4 = T3 * (V3 / V4)^(gamma - 1);
P4 = P3 * (V3 / V4)^gamma;

P_states = [P1, P2, P3, P4];
V_states = [V1, V2, V3, V4];
T_states = [T1, T2, T3, T4];

fprintf('==================================================\n');
fprintf('  STATE POINTS  (cutoff ratio rc = %6.4f)\n', rc);
fprintf('==================================================\n');
fprintf('  State    P [kPa]     V [m^3]      T [K]\n');
fprintf('  --------------------------------------------\n');
for i = 1:4
    fprintf('    %d    %9.2f   %9.6f   %8.2f\n', ...
            i, P_states(i)/1000, V_states(i), T_states(i));
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 4: HEAT AND WORK FOR EACH PROCESS
% ------------------------------------------------------------------------

% 1 -> 2 isentropic compression
Q_12 = 0;
W_12 = m * cv * (T1 - T2);

% 2 -> 3 constant pressure: Q = m*cp*dT, W = P*dV = m*R*dT
Q_23 = m * cp * (T3 - T2);
W_23 = m * R  * (T3 - T2);

% 3 -> 4 isentropic expansion
Q_34 = 0;
W_34 = m * cv * (T3 - T4);

% 4 -> 1 constant volume heat rejection
W_41 = 0;
Q_41 = m * cv * (T1 - T4);

Q_processes = [Q_12, Q_23, Q_34, Q_41];
W_processes = [W_12, W_23, W_34, W_41];
labels = {'1->2 isentropic comp', '2->3 const-P heat in', ...
          '3->4 isentropic exp', '4->1 const-V heat out'};

fprintf('==================================================\n');
fprintf('  HEAT AND WORK PER PROCESS\n');
fprintf('==================================================\n');
fprintf('  Process                    Q [kJ]      W [kJ]\n');
fprintf('  ------------------------------------------------\n');
for i = 1:4
    fprintf('  %-22s  %9.3f   %9.3f\n', ...
            labels{i}, Q_processes(i)/1000, W_processes(i)/1000);
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 5: CYCLE TOTALS AND EFFICIENCY
% ------------------------------------------------------------------------

Q_out   = abs(Q_41);
W_net   = sum(W_processes);
eta_cycle = W_net / Q_23;
eta_ideal = 1 - (1 / r^(gamma - 1)) * (rc^gamma - 1) / (gamma * (rc - 1));
energy_balance = (Q_23 - Q_out) - W_net;

V_disp = V1 - V2;
MEP = W_net / V_disp;

fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY\n');
fprintf('==================================================\n');
fprintf('  Heat added Q_in       = %9.3f kJ\n', Q_23/1000);
fprintf('  Heat rejected Q_out   = %9.3f kJ\n', Q_out/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Ideal Diesel eff.     = %9.4f  (%.2f%%)\n', eta_ideal, eta_ideal*100);
fprintf('  Mean eff. pressure    = %9.3f kPa\n', MEP/1000);
fprintf('  Energy balance resid  = %9.3e kJ (should be ~0)\n', energy_balance/1000);
fprintf('\n');

if abs(eta_cycle - eta_ideal) < 1e-6
    fprintf('  CHECK PASSED: efficiency matches air-standard Diesel formula.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match formula.\n');
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 6: SMOOTH PROCESS CURVES FOR PLOTTING
% ------------------------------------------------------------------------

N = 100;

% 1 -> 2 isentropic
V_12 = linspace(V1, V2, N);
P_12 = P1 * (V1 ./ V_12).^gamma;

% 2 -> 3 constant pressure (horizontal on P-V)
V_23 = linspace(V2, V3, N);
P_23 = P2 * ones(1, N);

% 3 -> 4 isentropic
V_34 = linspace(V3, V4, N);
P_34 = P3 * (V3 ./ V_34).^gamma;

% 4 -> 1 constant volume (vertical on P-V)
P_41 = linspace(P4, P1, N);
V_41 = V4 * ones(1, N);

V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];

%% ------------------------------------------------------------------------
%  SECTION 7: ENTROPY VALUES FOR THE T-S DIAGRAM
% ------------------------------------------------------------------------

s1 = 0;
s2 = s1;                            % 1->2 isentropic
s3 = s2 + cp * log(T3 / T2);        % 2->3 constant pressure
s4 = s3;                            % 3->4 isentropic

s_states = [s1, s2, s3, s4];

T_23s = linspace(T2, T3, N);
s_23s = s2 + cp * log(T_23s / T2);
T_41s = linspace(T4, T1, N);
s_41s = s4 + cv * log(T_41s / T4);

s_TS = [s1, s2, s_23s, s3, s4, s_41s, s1];
T_TS = [T1, T2, T_23s, T3, T4, T_41s, T1];

%% ------------------------------------------------------------------------
%  SECTION 8: PLOTTING
% ------------------------------------------------------------------------

figure('Name', 'Diesel Cycle P-V Diagram', 'Color', 'w');
plot(V_curve, P_curve/1000, 'b-', 'LineWidth', 2);
hold on;
plot(V_states, P_states/1000, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
for i = 1:4
    text(V_states(i), P_states(i)/1000, sprintf('  %d', i), ...
         'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Volume V [m^3]');
ylabel('Pressure P [kPa]');
title('Diesel Cycle: P-V Diagram');
grid on;
hold off;

figure('Name', 'Diesel Cycle T-S Diagram', 'Color', 'w');
plot(s_TS, T_TS, 'r-', 'LineWidth', 2);
hold on;
plot(s_states, T_states, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
for i = 1:4
    text(s_states(i), T_states(i), sprintf('  %d', i), ...
         'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Entropy change s [J/(kg*K)]');
ylabel('Temperature T [K]');
title('Diesel Cycle: T-S Diagram');
grid on;
hold off;

fprintf('Plots generated. Diesel cycle model complete.\n');

%% ========================================================================
%  END OF DIESEL CYCLE MODEL
% ========================================================================
