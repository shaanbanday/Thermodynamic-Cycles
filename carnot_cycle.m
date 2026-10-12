%% ========================================================================
%  CARNOT CYCLE MODEL
%  Repository: thermodynamic-cycles
%  Working fluid: ideal gas (air, air-standard assumptions)
%
%  The Carnot cycle is the theoretical benchmark for all heat engines.
%  It consists of four reversible processes:
%     1 -> 2 : Isothermal expansion   (heat added at T_hot)
%     2 -> 3 : Isentropic expansion    (temperature drops T_hot -> T_cold)
%     3 -> 4 : Isothermal compression (heat rejected at T_cold)
%     4 -> 1 : Isentropic compression  (temperature rises T_cold -> T_hot)
%
%  Because all processes are reversible and heat transfer happens only at
%  the two temperature extremes, the Carnot cycle achieves the maximum
%  possible efficiency for given hot and cold reservoir temperatures.
% ========================================================================

clear;            % remove all variables from the workspace
clc;              % clear the command window
close all;        % close any open figure windows

%% ------------------------------------------------------------------------
%  SECTION 1: WORKING FLUID PROPERTIES (AIR, IDEAL GAS)
% ------------------------------------------------------------------------

R     = 287;      % specific gas constant for air            [J/(kg*K)]
gamma = 1.4;      % ratio of specific heats, cp/cv, for air  [-]
cv    = R / (gamma - 1);   % specific heat at constant volume [J/(kg*K)]
cp    = gamma * cv;        % specific heat at constant pressure [J/(kg*K)]

% Print the fluid properties so the user can confirm the assumptions
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

m       = 1.0;        % mass of working fluid                [kg]
T_hot   = 800;        % hot reservoir temperature            [K]
T_cold  = 300;        % cold reservoir temperature           [K]

% State 1 is defined as the start of isothermal expansion (hottest, highest P)
P1      = 1000e3;     % pressure at state 1                  [Pa]
V1      = m * R * T_hot / P1;   % volume at state 1 from ideal gas law [m^3]

% The compression ratio during isothermal expansion (1 -> 2) is a free
% design choice. It sets how much the gas expands at constant T_hot.
r_iso   = 2.0;        % isothermal expansion volume ratio V2/V1 [-]

fprintf('==================================================\n');
fprintf('  CYCLE INPUT PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Mass m                = %8.3f kg\n', m);
fprintf('  Hot temperature T_hot = %8.3f K\n', T_hot);
fprintf('  Cold temperature T_cold = %6.3f K\n', T_cold);
fprintf('  Pressure at state 1   = %8.3f kPa\n', P1/1000);
fprintf('  Volume at state 1     = %8.6f m^3\n', V1);
fprintf('  Isothermal vol ratio  = %8.3f\n', r_iso);
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 3: STATE POINT CALCULATIONS
%  Work around the cycle 1 -> 2 -> 3 -> 4 -> 1, finding P, V, T at each.
% ------------------------------------------------------------------------

% ----- STATE 1 (already defined above) -----
T1 = T_hot;           % isothermal expansion happens at T_hot
% P1, V1 already known

% ----- STATE 2: end of isothermal expansion (1 -> 2) -----
% Temperature is constant along an isotherm, so T2 = T1 = T_hot.
T2 = T_hot;
V2 = r_iso * V1;                 % volume expands by the chosen ratio
P2 = m * R * T2 / V2;            % pressure from ideal gas law

% ----- STATE 3: end of isentropic expansion (2 -> 3) -----
% Temperature drops from T_hot to T_cold with no heat transfer.
T3 = T_cold;
% For an isentropic process: T * V^(gamma-1) = constant
% So V3 = V2 * (T2/T3)^(1/(gamma-1))
V3 = V2 * (T2 / T3)^(1 / (gamma - 1));
P3 = m * R * T3 / V3;            % pressure from ideal gas law

% ----- STATE 4: end of isothermal compression (3 -> 4) -----
% Temperature stays at T_cold. State 4 must line up so that the final
% isentropic compression (4 -> 1) returns exactly to state 1.
T4 = T_cold;
% Work backwards from state 1 through the isentropic process 4 -> 1:
% T4 * V4^(gamma-1) = T1 * V1^(gamma-1)
% So V4 = V1 * (T1/T4)^(1/(gamma-1))
V4 = V1 * (T1 / T4)^(1 / (gamma - 1));
P4 = m * R * T4 / V4;            % pressure from ideal gas law

% Collect the state points into arrays for printing and plotting
P_states = [P1, P2, P3, P4];     % pressures [Pa]
V_states = [V1, V2, V3, V4];     % volumes   [m^3]
T_states = [T1, T2, T3, T4];     % temperatures [K]

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
%  SECTION 4: HEAT AND WORK FOR EACH PROCESS
% ------------------------------------------------------------------------

% ----- Process 1 -> 2: isothermal expansion at T_hot -----
% For isothermal ideal-gas processes: Q = W = m*R*T*ln(V2/V1).
% Heat is absorbed (positive) and work is done by the gas (positive).
W_12 = m * R * T_hot * log(V2 / V1);   % work out [J]
Q_12 = W_12;                            % Q = W for isothermal [J]

% ----- Process 2 -> 3: isentropic expansion -----
% No heat transfer. Work done by the gas equals the drop in internal energy.
Q_23 = 0;                               % adiabatic, no heat [J]
W_23 = m * cv * (T2 - T3);              % work out = -dU [J]

% ----- Process 3 -> 4: isothermal compression at T_cold -----
% Heat is rejected (negative) and work is done on the gas (negative).
W_34 = m * R * T_cold * log(V4 / V3);   % work (negative) [J]
Q_34 = W_34;                            % Q = W for isothermal [J]

% ----- Process 4 -> 1: isentropic compression -----
% No heat transfer. Work done on the gas raises its internal energy.
Q_41 = 0;                               % adiabatic, no heat [J]
W_41 = m * cv * (T4 - T1);              % work (negative) [J]

% Collect for printing
Q_processes = [Q_12, Q_23, Q_34, Q_41]; % heat per process [J]
W_processes = [W_12, W_23, W_34, W_41]; % work per process [J]
labels = {'1->2 iso-T exp', '2->3 isentropic exp', ...
          '3->4 iso-T comp', '4->1 isentropic comp'};

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

Q_in    = Q_12;                      % heat added (only process 1->2) [J]
Q_out   = abs(Q_34);                 % heat rejected (magnitude)      [J]
W_net   = sum(W_processes);          % net work out of the cycle      [J]

% Thermal efficiency: net work divided by heat input
eta_cycle = W_net / Q_in;

% Carnot efficiency: the theoretical maximum for these two temperatures
eta_carnot = 1 - (T_cold / T_hot);

% Energy balance check: net work should equal net heat (Q_in - Q_out)
energy_balance = (Q_in - Q_out) - W_net;   % should be ~0 [J]

fprintf('==================================================\n');
fprintf('  CYCLE TOTALS AND EFFICIENCY\n');
fprintf('==================================================\n');
fprintf('  Heat added Q_in       = %9.3f kJ\n', Q_in/1000);
fprintf('  Heat rejected Q_out   = %9.3f kJ\n', Q_out/1000);
fprintf('  Net work W_net        = %9.3f kJ\n', W_net/1000);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', ...
        eta_cycle, eta_cycle*100);
fprintf('  Carnot efficiency     = %9.4f  (%.2f%%)\n', ...
        eta_carnot, eta_carnot*100);
fprintf('  Energy balance resid  = %9.3e kJ (should be ~0)\n', ...
        energy_balance/1000);
fprintf('\n');

% Sanity check: the computed efficiency should match the Carnot limit,
% because this IS a Carnot cycle. Flag it if they disagree.
if abs(eta_cycle - eta_carnot) < 1e-6
    fprintf('  CHECK PASSED: cycle efficiency matches Carnot limit.\n');
else
    fprintf('  CHECK FAILED: efficiency does not match Carnot limit.\n');
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  SECTION 6: BUILD SMOOTH PROCESS CURVES FOR PLOTTING
%  State points alone give four dots. To draw the actual curves we
%  generate many intermediate points along each process path.
% ------------------------------------------------------------------------

N = 100;          % number of points per process segment

% ----- Process 1 -> 2: isothermal (P*V = constant, T = T_hot) -----
V_12 = linspace(V1, V2, N);           % volume sweep
P_12 = m * R * T1 ./ V_12;            % pressure from ideal gas law
T_12 = T1 * ones(1, N);               % constant temperature

% ----- Process 2 -> 3: isentropic (P*V^gamma = constant) -----
V_23 = linspace(V2, V3, N);
P_23 = P2 * (V2 ./ V_23).^gamma;      % isentropic P-V relation
T_23 = P_23 .* V_23 / (m * R);        % temperature from ideal gas law

% ----- Process 3 -> 4: isothermal (T = T_cold) -----
V_34 = linspace(V3, V4, N);
P_34 = m * R * T3 ./ V_34;
T_34 = T3 * ones(1, N);

% ----- Process 4 -> 1: isentropic -----
V_41 = linspace(V4, V1, N);
P_41 = P4 * (V4 ./ V_41).^gamma;
T_41 = P_41 .* V_41 / (m * R);

% Stitch the four segments into continuous curves for the P-V diagram
V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];
T_curve = [T_12, T_23, T_34, T_41];

%% ------------------------------------------------------------------------
%  SECTION 7: ENTROPY VALUES FOR THE T-S DIAGRAM
%  Entropy only changes during the isothermal processes. We set a
%  reference of s = 0 at state 1 and track changes around the cycle.
% ------------------------------------------------------------------------

s1 = 0;                                   % reference entropy at state 1 [J/(kg*K)]
% 1 -> 2 isothermal: ds = R*ln(V2/V1)
s2 = s1 + R * log(V2 / V1);
% 2 -> 3 isentropic: entropy constant
s3 = s2;
% 3 -> 4 isothermal: ds = R*ln(V4/V3)  (negative, heat rejected)
s4 = s3 + R * log(V4 / V3);
% 4 -> 1 isentropic: entropy constant, returns to s1
s_check = s4 + R * 0;    % no entropy change on isentropic leg

s_states = [s1, s2, s3, s4];

% Build the T-S rectangle (Carnot cycles are rectangles on T-S axes)
s_TS = [s1, s2, s3, s4, s1];              % close the loop back to s1
T_TS = [T1, T2, T3, T4, T1];              % temperatures at each corner

%% ------------------------------------------------------------------------
%  SECTION 8: PLOTTING
% ------------------------------------------------------------------------

% ----- Figure 1: P-V diagram -----
figure('Name', 'Carnot Cycle P-V Diagram', 'Color', 'w');
plot(V_curve, P_curve/1000, 'b-', 'LineWidth', 2);   % curve in kPa
hold on;
plot(V_states, P_states/1000, 'ro', ...              % state point markers
     'MarkerFaceColor', 'r', 'MarkerSize', 8);
% Label each state point
for i = 1:4
    text(V_states(i), P_states(i)/1000, ...
         sprintf('  %d', i), 'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Volume V [m^3]');
ylabel('Pressure P [kPa]');
title('Carnot Cycle: P-V Diagram');
grid on;
hold off;

% ----- Figure 2: T-S diagram -----
figure('Name', 'Carnot Cycle T-S Diagram', 'Color', 'w');
plot(s_TS, T_TS, 'r-', 'LineWidth', 2);              % the rectangle
hold on;
plot(s_states, T_states, 'bo', ...                   % state markers
     'MarkerFaceColor', 'b', 'MarkerSize', 8);
for i = 1:4
    text(s_states(i), T_states(i), ...
         sprintf('  %d', i), 'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Entropy change s [J/(kg*K)]');
ylabel('Temperature T [K]');
title('Carnot Cycle: T-S Diagram (rectangle)');
grid on;
hold off;

fprintf('Plots generated. Carnot cycle model complete.\n');

%% ========================================================================
%  END OF CARNOT CYCLE MODEL
% ========================================================================
