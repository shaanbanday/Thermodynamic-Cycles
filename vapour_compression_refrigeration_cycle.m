%% ========================================================================
%  VAPOUR-COMPRESSION REFRIGERATION CYCLE (ideal)
%  Repository: thermodynamic-cycles
%  Working fluid: R-134a  -- enthalpy-based, NOT ideal-gas air
%
%  Standard refrigeration / heat-pump cycle. Four processes:
%     1 -> 2 : Isentropic compression (sat vapour -> condenser pressure)
%     2 -> 3 : Constant-pressure heat rejection in condenser (-> sat liq)
%     3 -> 4 : Throttle through expansion valve (h constant)
%     4 -> 1 : Constant-pressure heat absorption in evaporator (-> sat vap)
%
%  COP_cooling = q_evap / w_comp,  COP_heating = q_cond / w_comp.
%
%  PROPERTY VALUES below are standard R-134a table values for the chosen
%  evaporator/condenser temperatures. The superheated value h2 in
%  particular should be VERIFIED by lookup at (P_cond, s1).
% ========================================================================

clear; clc; close all;

%% SECTION 1: CYCLE CONDITIONS
T_evap = -20;   % evaporator temperature   [degC]
T_cond =  40;   % condenser temperature    [degC]

fprintf('==================================================\n');
fprintf('  VAPOUR-COMPRESSION CYCLE CONDITIONS (R-134a)\n');
fprintf('==================================================\n');
fprintf('  Evaporator temperature = %7.1f degC\n', T_evap);
fprintf('  Condenser temperature  = %7.1f degC\n', T_cond);
fprintf('\n');

%% SECTION 2: R-134a PROPERTIES  (VERIFY AGAINST YOUR TABLES)
% --- State 1: saturated vapour at evaporator temp (-20 degC) ---
P_evap = 132.8;     % saturation pressure        [kPa]
h1 = 238.43;        % sat vapour enthalpy        [kJ/kg]
s1 = 0.94565;       % sat vapour entropy         [kJ/(kg*K)]

% --- State 3: saturated liquid at condenser temp (40 degC) ---
P_cond = 1017.0;    % saturation pressure        [kPa]
h3 = 108.26;        % sat liquid enthalpy        [kJ/kg]

% --- State 2: superheated vapour at P_cond with s2 = s1 ---
% From a superheated R-134a lookup at ~1017 kPa, s = 0.94565.
% VERIFY this one; it drives the compressor work directly.
h2 = 275.39;        % compressor exit enthalpy   [kJ/kg]

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
s2 = s1;                    % isentropic compression
% State 4: throttle is isenthalpic, h4 = h3
h4 = h3;
% Quality at evaporator inlet (state 4) for reference
% x4 would need hf, hfg at evaporator temp; left out to avoid extra guesses

h_states = [h1, h2, h3, h4];
P_states = [P_evap, P_cond, P_cond, P_evap];
fprintf('==================================================\n');
fprintf('  STATE POINTS\n');
fprintf('==================================================\n');
fprintf('  State    P [kPa]    h [kJ/kg]    note\n');
fprintf('  ------------------------------------------------\n');
fprintf('    1     %8.1f   %9.2f    sat vapour (evap out)\n', P_evap, h1);
fprintf('    2     %8.1f   %9.2f    superheated (comp out)\n', P_cond, h2);
fprintf('    3     %8.1f   %9.2f    sat liquid (cond out)\n', P_cond, h3);
fprintf('    4     %8.1f   %9.2f    two-phase (valve out)\n', P_evap, h4);
fprintf('\n');

%% SECTION 4: WORK, HEAT, COP
w_comp  = h2 - h1;      % compressor work in   [kJ/kg]
q_evap  = h1 - h4;      % refrigeration effect [kJ/kg]
q_cond  = h2 - h3;      % heat rejected        [kJ/kg]

COP_cool = q_evap / w_comp;     % as a refrigerator
COP_heat = q_cond / w_comp;     % as a heat pump
energy_balance = q_cond - (q_evap + w_comp);   % should be ~0

% Reversed-Carnot COP between the two temperatures, as an upper-bound ref
Tc = T_evap + 273.15;  Th = T_cond + 273.15;
COP_cool_carnot = Tc / (Th - Tc);

fprintf('==================================================\n');
fprintf('  WORK, HEAT, COP  (per kg of refrigerant)\n');
fprintf('==================================================\n');
fprintf('  Compressor work in    = %9.3f kJ/kg\n', w_comp);
fprintf('  Refrigeration effect  = %9.3f kJ/kg\n', q_evap);
fprintf('  Heat rejected         = %9.3f kJ/kg\n', q_cond);
fprintf('  COP (cooling)         = %9.4f\n', COP_cool);
fprintf('  COP (heating)         = %9.4f\n', COP_heat);
fprintf('  Carnot COP (cooling)  = %9.4f  (upper bound)\n', COP_cool_carnot);
fprintf('  Energy balance resid  = %9.3e kJ/kg (should be ~0)\n', energy_balance);
fprintf('\n');

%% SECTION 5: P-h DIAGRAM (the natural refrigeration diagram)
% Cycle path through the four points on pressure-enthalpy axes. A full
% dome needs the sat table; the state-point path shows the cycle shape.
h_path = [h1, h2, h3, h4, h1];
P_path = [P_evap, P_cond, P_cond, P_evap, P_evap];

figure('Name','Vapour-Compression P-h Diagram','Color','w');
plot(h_path, P_path, 'b-', 'LineWidth', 2); hold on;
plot(h_states, P_states, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
for i = 1:4
    text(h_states(i), P_states(i), sprintf('  %d', i), ...
         'FontSize', 12, 'FontWeight', 'bold');
end
set(gca, 'YScale', 'log');          % P-h diagrams use a log pressure axis
xlabel('Enthalpy h [kJ/kg]');
ylabel('Pressure P [kPa] (log scale)');
title('Vapour-Compression Cycle: P-h Diagram');
grid on; hold off;

fprintf('Plot generated. Vapour-compression model complete.\n');
%% END OF VAPOUR-COMPRESSION MODEL
