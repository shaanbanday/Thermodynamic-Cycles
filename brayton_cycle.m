%% ========================================================================
%  BRAYTON (JOULE) CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard, cold-air assumptions)
%
%  Gas-turbine / jet-engine idealization. Steady-flow cycle, so work and
%  heat use enthalpy (cp). Four processes:
%     1 -> 2 : Isentropic compression (compressor)
%     2 -> 3 : Constant-pressure heat addition (combustor)
%     3 -> 4 : Isentropic expansion (turbine)
%     4 -> 1 : Constant-pressure heat rejection (exhaust, idealized)
%
%  eta = 1 - 1/rp^((gamma-1)/gamma),  rp = pressure ratio P2/P1
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

m     = 1.0;                % mass flow basis                  [kg]
T1    = 300;                % compressor inlet temperature     [K]
P1    = 100e3;              % compressor inlet pressure        [Pa]
rp    = 10.0;               % pressure ratio P2/P1             [-]
T3    = 1400;               % turbine inlet temperature (TIT)  [K]

% Pressure-ratio exponent for isentropic ideal-gas relations
pexp  = (gamma - 1) / gamma;

V1    = m * R * T1 / P1;    % specific volume basis at state 1 [m^3]

fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass basis m          = %8.3f kg\n', m);
fprintf('  Inlet temperature T1  = %8.3f K\n', T1);
fprintf('  Inlet pressure P1     = %8.3f kPa\n', P1/1000);
fprintf('  Pressure ratio rp     = %8.3f\n', rp);
fprintf('  Turbine inlet T3      = %8.3f K\n', T3);
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
% ------------------------------------------------------------------------

% ----- STATE 2: isentropic compression (1 -> 2) -----
P2 = rp * P1;
T2 = T1 * rp^pexp;
V2 = m * R * T2 / P2;

% ----- STATE 3: constant-pressure heat addition (2 -> 3) -----
P3 = P2;                        % combustor is constant pressure
% T3 given as turbine inlet temperature
V3 = m * R * T3 / P3;

% ----- STATE 4: isentropic expansion (3 -> 4) -----
P4 = P1;                        % expands back to inlet pressure
T4 = T3 * (1 / rp)^pexp;
V4 = m * R * T4 / P4;

P_states = [P1, P2, P3, P4];
V_states = [V1, V2, V3, V4];
T_states = [T1, T2, T3, T4];

fprintf('==================================================\n');
fprintf('  STATE POINTS\n');
fprintf('==================================================\n');
fprintf('  State    P [kPa]     V [m^3]      T [K]\n');
fprintf('  --------------------------------------------\n');
for i = 1:4
    fprintf('    %d    %9.2f   %9.6f   %8.2f\n', ...
            i, P_states(i)/1000, V_states(i), T_states(i));
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 4: HEAT AND WORK FOR EACH PROCESS (STEADY FLOW, cp BASIS)
% ------------------------------------------------------------------------

% 1 -> 2 compressor: w = dh = cp*dT (work in, negative out of system)
Q_12 = 0;
W_12 = m * cp * (T1 - T2);

% 2 -> 3 combustor: constant-pressure heat in, no shaft work
Q_23 = m * cp * (T3 - T2);
W_23 = 0;

% 3 -> 4 turbine: w = dh = cp*dT (work out, positive)
Q_34 = 0;
W_34 = m * cp * (T3 - T4);

% 4 -> 1 exhaust: constant-pressure heat out, no shaft work
Q_41 = m * cp * (T1 - T4);
W_41 = 0;

Q_processes = [Q_12, Q_23, Q_34, Q_41];
W_processes = [W_12, W_23, W_34, W_41];
labels = {'1->2 compressor', '2->3 const-P heat in', ...
          '3->4 turbine', '4->1 const-P heat out'};

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
%  SECTION 5: CYCLE TOTALS, EFFICIENCY, BACK-WORK RATIO
% ------------------------------------------------------------------------

W_comp  = abs(W_12);            % compressor work input
W_turb  = W_34;                 % turbine work output
Q_out   = abs(Q_41);
W_net   = sum(W_processes);
eta_cycle = W_net / Q_23;
eta_ideal = 1 - 1 / rp^pexp;
bwr     = W_comp / W_turb;      % back-work ratio (large for gas turbines)
energy_balance = (Q_23 - Q_out) - W_net;

fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY\n');
fprintf('==================================================\n');
fprintf('  Compressor work in    = %9.3f kJ\n', W_comp/1000);
fprintf('  Turbine work out      = %9.3f kJ\n', W_turb/1000);
fprintf('  Heat added Q_in       = %9.3f kJ\n', Q_23/1000);
fprintf('  Heat rejected Q_out   = %9.3f kJ\n', Q_out/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Back-work ratio       = %9.4f\n', bwr);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_cycle, eta_cycle*100);
fprintf('  Ideal Brayton eff.    = %9.4f  (%.2f%%)\n', eta_ideal, eta_ideal*100);
fprintf('  Energy balance resid  = %9.3e kJ (should be ~0)\n', energy_balance/1000);
fprintf('\n');

if abs(eta_cycle - eta_ideal) < 1e-6
    fprintf('  CHECK PASSED: efficiency matches air-standard Brayton formula.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match formula.\n');
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 6: SMOOTH PROCESS CURVES FOR PLOTTING (P-V uses specific volume)
% ------------------------------------------------------------------------

N = 100;

% 1 -> 2 isentropic (P*V^gamma = const)
V_12 = linspace(V1, V2, N);
P_12 = P1 * (V1 ./ V_12).^gamma;

% 2 -> 3 constant pressure
V_23 = linspace(V2, V3, N);
P_23 = P2 * ones(1, N);

% 3 -> 4 isentropic
V_34 = linspace(V3, V4, N);
P_34 = P3 * (V3 ./ V_34).^gamma;

% 4 -> 1 constant pressure
V_41 = linspace(V4, V1, N);
P_41 = P4 * ones(1, N);

V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];

%% ------------------------------------------------------------------------
%  SECTION 7: ENTROPY VALUES FOR THE T-S DIAGRAM
%  Entropy changes on the constant-pressure legs: ds = cp*ln(T_end/T_start)
% ------------------------------------------------------------------------

s1 = 0;
s2 = s1;                            % 1->2 isentropic
s3 = s2 + cp * log(T3 / T2);        % 2->3 constant pressure
s4 = s3;                            % 3->4 isentropic

s_states = [s1, s2, s3, s4];

T_23s = linspace(T2, T3, N);
s_23s = s2 + cp * log(T_23s / T2);
T_41s = linspace(T4, T1, N);
s_41s = s4 + cp * log(T_41s / T4);

s_TS = [s1, s2, s_23s, s3, s4, s_41s, s1];
T_TS = [T1, T2, T_23s, T3, T4, T_41s, T1];

%% ------------------------------------------------------------------------
%  SECTION 8: PLOTTING
% ------------------------------------------------------------------------

figure('Name', 'Brayton Cycle P-V Diagram', 'Color', 'w');
plot(V_curve, P_curve/1000, 'b-', 'LineWidth', 2);
hold on;
plot(V_states, P_states/1000, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
for i = 1:4
    text(V_states(i), P_states(i)/1000, sprintf('  %d', i), ...
         'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Specific volume v [m^3/kg]');
ylabel('Pressure P [kPa]');
title('Brayton Cycle: P-V Diagram');
grid on;
hold off;

figure('Name', 'Brayton Cycle T-S Diagram', 'Color', 'w');
plot(s_TS, T_TS, 'r-', 'LineWidth', 2);
hold on;
plot(s_states, T_states, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
for i = 1:4
    text(s_states(i), T_states(i), sprintf('  %d', i), ...
         'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Entropy change s [J/(kg*K)]');
ylabel('Temperature T [K]');
title('Brayton Cycle: T-S Diagram');
grid on;
hold off;

fprintf('Plots generated. Brayton cycle model complete.\n');

%% ========================================================================
%  END OF BRAYTON CYCLE MODEL
% ========================================================================
