%% ========================================================================
%  PELTIER (THERMOELECTRIC) COOLER MODEL
%  Repository: thermodynamic-cycles
%
%  Not a fluid cycle. A thermoelectric module driven by current I pumps
%  heat from a cold side (Tc) to a hot side (Th). Governing relations:
%     Q_c = alpha*I*Tc - 0.5*I^2*R - K*(Th - Tc)   cooling power at cold side
%     Q_h = alpha*I*Th + 0.5*I^2*R - K*(Th - Tc)   heat dumped at hot side
%     P   = Q_h - Q_c = alpha*I*(Th - Tc) + I^2*R   electrical power in
%     COP = Q_c / P                                 cooling coefficient
%  Figure of merit: ZT = alpha^2 * T_avg / (R*K)
%
%  Three terms in Q_c: Peltier pumping (alpha*I*Tc, helps), Joule heating
%  (half of I^2*R leaks back to cold side, hurts), and conduction leakage
%  (K*(Th-Tc), hurts). The trade-off gives an optimal current.
% ========================================================================

clear; clc; close all;

%% SECTION 1: MODULE PARAMETERS  (typical single-module values)
alpha = 0.0530;    % module Seebeck coefficient   [V/K]
R     = 2.10;      % module electrical resistance [ohm]
K     = 0.470;     % module thermal conductance   [W/K]
Tc    = 273.15;    % cold-side temperature        [K]  (0 degC)
Th    = 300.15;    % hot-side temperature         [K]  (27 degC)

dT    = Th - Tc;               % temperature difference [K]
T_avg = 0.5 * (Th + Tc);       % mean temperature       [K]
ZT    = alpha^2 * T_avg / (R * K);   % figure of merit  [-]

fprintf('==================================================\n');
fprintf('  THERMOELECTRIC MODULE PARAMETERS\n');
fprintf('==================================================\n');
fprintf('  Seebeck coefficient   = %8.4f V/K\n', alpha);
fprintf('  Electrical resistance = %8.4f ohm\n', R);
fprintf('  Thermal conductance   = %8.4f W/K\n', K);
fprintf('  Cold-side temp Tc     = %8.2f K\n', Tc);
fprintf('  Hot-side temp Th      = %8.2f K\n', Th);
fprintf('  Temperature diff dT   = %8.2f K\n', dT);
fprintf('  Figure of merit ZT    = %8.4f\n', ZT);
fprintf('\n');

%% SECTION 2: KEY OPERATING CURRENTS
% Current that maximizes cooling power: dQc/dI = alpha*Tc - I*R = 0
I_maxQc = alpha * Tc / R;

% Current that maximizes COP (standard TE result):
% I_optCOP = alpha*dT / (R*(sqrt(1 + ZT) - 1))
I_optCOP = alpha * dT / (R * (sqrt(1 + ZT) - 1));

% Maximum temperature difference at zero cooling load (Qc = 0), reference:
% dT_max = 0.5 * ZT * Tc^2 / T_avg  (approx, small-dT form)
dT_max = 0.5 * ZT * Tc^2 / T_avg;

fprintf('==================================================\n');
fprintf('  KEY OPERATING CURRENTS\n');
fprintf('==================================================\n');
fprintf('  I for max cooling Qc  = %8.3f A\n', I_maxQc);
fprintf('  I for max COP         = %8.3f A\n', I_optCOP);
fprintf('  Approx dT_max (Qc=0)  = %8.3f K\n', dT_max);
fprintf('\n');

%% SECTION 3: PERFORMANCE AT THE TWO KEY CURRENTS
currents = [I_maxQc, I_optCOP];
names    = {'max cooling', 'max COP'};
fprintf('==================================================\n');
fprintf('  PERFORMANCE AT KEY CURRENTS\n');
fprintf('==================================================\n');
fprintf('  Operating point   I [A]    Qc [W]    P [W]    COP\n');
fprintf('  ----------------------------------------------------\n');
for i = 1:2
    I   = currents(i);
    Qc  = alpha*I*Tc - 0.5*I^2*R - K*dT;
    P   = alpha*I*dT + I^2*R;
    COP = Qc / P;
    fprintf('  %-14s  %7.3f  %8.3f  %7.3f  %6.4f\n', ...
            names{i}, I, Qc, P, COP);
end
fprintf('\n');

%% SECTION 4: SWEEP CURRENT AND COMPUTE CURVES
N = 300;
I_sweep  = linspace(0.01, 1.4 * I_maxQc, N);   % avoid I = 0 for COP
Qc_sweep = alpha .* I_sweep .* Tc - 0.5 .* I_sweep.^2 .* R - K*dT;
Qh_sweep = alpha .* I_sweep .* Th + 0.5 .* I_sweep.^2 .* R - K*dT;
P_sweep  = alpha .* I_sweep .* dT + I_sweep.^2 .* R;
COP_sweep = Qc_sweep ./ P_sweep;
COP_sweep(Qc_sweep < 0) = 0;   % no useful cooling once Qc goes negative

%% SECTION 5: PLOTTING
figure('Name','Peltier: Cooling Power and Input Power','Color','w');
plot(I_sweep, Qc_sweep, 'b-', 'LineWidth', 2); hold on;
plot(I_sweep, P_sweep,  'r-', 'LineWidth', 2);
plot(I_sweep, Qh_sweep, 'k--', 'LineWidth', 1.5);
xline(I_maxQc, 'b:', 'LineWidth', 1);
xline(I_optCOP, 'g:', 'LineWidth', 1);
legend('Q_c cooling power', 'P electrical in', 'Q_h heat rejected', ...
       'I for max Q_c', 'I for max COP', 'Location', 'northwest');
xlabel('Current I [A]');
ylabel('Power [W]');
title('Peltier Module: Power vs Current');
grid on; hold off;

figure('Name','Peltier: COP vs Current','Color','w');
plot(I_sweep, COP_sweep, 'm-', 'LineWidth', 2); hold on;
xline(I_optCOP, 'g:', 'LineWidth', 1);
legend('COP (cooling)', 'I for max COP', 'Location', 'northeast');
xlabel('Current I [A]');
ylabel('COP [-]');
title('Peltier Module: Cooling COP vs Current');
grid on; hold off;

fprintf('Plots generated. Peltier model complete.\n');
%% END OF PELTIER MODEL
