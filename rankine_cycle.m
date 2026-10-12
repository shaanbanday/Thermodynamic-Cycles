%% ========================================================================
%  RANKINE CYCLE MODEL (ideal, basic)
%  Repository: thermodynamic-cycles
%  Working fluid: water/steam  -- enthalpy-based, NOT ideal-gas air
%
%  Steam power plant idealization. Four processes:
%     1 -> 2 : Isentropic pump (sat liquid -> boiler pressure)
%     2 -> 3 : Constant-pressure heat addition in boiler (-> superheat)
%     3 -> 4 : Isentropic expansion through turbine
%     4 -> 1 : Constant-pressure heat rejection in condenser (-> sat liquid)
%
%  Work and heat use enthalpy (h), not cp*dT, because the fluid changes
%  phase. Efficiency = w_net / q_in.
%
%  PROPERTY VALUES below are from standard steam tables for the chosen
%  boiler/condenser conditions. VERIFY against your own reference before
%  trusting the output.
% ========================================================================

clear; clc; close all;

%% SECTION 1: CYCLE CONDITIONS
P_boiler = 8000;    % boiler pressure                 [kPa]
T_boiler = 480;     % turbine inlet (superheat) temp  [degC]
P_cond   = 10;      % condenser pressure              [kPa]

fprintf('==================================================\n');
fprintf('  RANKINE CYCLE CONDITIONS\n');
fprintf('==================================================\n');
fprintf('  Boiler pressure       = %8.1f kPa\n', P_boiler);
fprintf('  Turbine inlet temp    = %8.1f degC\n', T_boiler);
fprintf('  Condenser pressure    = %8.1f kPa\n', P_cond);
fprintf('\n');

%% SECTION 2: STEAM PROPERTIES  (VERIFY AGAINST YOUR TABLES)
% --- Saturated liquid at condenser pressure (10 kPa) ---
hf_cond  = 191.83;      % sat liquid enthalpy        [kJ/kg]
vf_cond  = 0.001010;    % sat liquid specific volume [m^3/kg]
sf_cond  = 0.6493;      % sat liquid entropy         [kJ/(kg*K)]
hfg_cond = 2392.8;      % enthalpy of vaporization   [kJ/kg]
sfg_cond = 7.5009;      % entropy of vaporization    [kJ/(kg*K)]
Tsat_cond = 45.81;      % saturation temperature     [degC]

% --- Superheated steam at boiler pressure (8 MPa, 480 degC) ---
h3 = 3348.4;            % turbine inlet enthalpy     [kJ/kg]
s3 = 6.6586;            % turbine inlet entropy      [kJ/(kg*K)]

%% SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
% ----- STATE 1: saturated liquid leaving condenser -----
h1 = hf_cond;
s1 = sf_cond;
v1 = vf_cond;
T1 = Tsat_cond;

% ----- STATE 2: after isentropic pump -----
% Pump work on incompressible liquid: wp = v1*(P2 - P1)
w_pump = v1 * (P_boiler - P_cond);     % [kJ/kg]  (kPa*m^3/kg = kJ/kg)
h2 = h1 + w_pump;
s2 = s1;                                % isentropic
T2 = T1;                                % negligible temp rise, approx

% ----- STATE 3: superheated steam leaving boiler (given) -----
T3 = T_boiler;
% h3, s3 from property block

% ----- STATE 4: after isentropic turbine expansion to condenser P -----
s4 = s3;                                % isentropic
x4 = (s4 - sf_cond) / sfg_cond;         % quality at turbine exit
h4 = hf_cond + x4 * hfg_cond;
T4 = Tsat_cond;                         % two-phase, at sat temperature

fprintf('==================================================\n');
fprintf('  STATE POINTS\n');
fprintf('==================================================\n');
fprintf('  State    h [kJ/kg]   s [kJ/(kg*K)]   T [degC]   note\n');
fprintf('  ------------------------------------------------------\n');
fprintf('    1     %9.2f     %8.4f     %7.2f   sat liquid\n', h1, s1, T1);
fprintf('    2     %9.2f     %8.4f     %7.2f   comp liquid\n', h2, s2, T2);
fprintf('    3     %9.2f     %8.4f     %7.2f   superheated\n', h3, s3, T3);
fprintf('    4     %9.2f     %8.4f     %7.2f   x = %5.4f\n', h4, s4, T4, x4);
fprintf('\n');

%% SECTION 4: WORK, HEAT, EFFICIENCY
w_turbine = h3 - h4;            % turbine work out   [kJ/kg]
w_net     = w_turbine - w_pump; % net work out       [kJ/kg]
q_in      = h3 - h2;            % boiler heat in     [kJ/kg]
q_out     = h4 - h1;            % condenser heat out [kJ/kg]

eta_thermal = w_net / q_in;     % thermal efficiency
bwr         = w_pump / w_turbine;   % back-work ratio (tiny for Rankine)
energy_balance = (q_in - q_out) - w_net;   % should be ~0

% Carnot efficiency between the two saturation temperatures, for reference
eta_carnot = 1 - (Tsat_cond + 273.15) / (T_boiler + 273.15);

fprintf('==================================================\n');
fprintf('  WORK, HEAT, EFFICIENCY  (per kg of steam)\n');
fprintf('==================================================\n');
fprintf('  Pump work in          = %9.3f kJ/kg\n', w_pump);
fprintf('  Turbine work out      = %9.3f kJ/kg\n', w_turbine);
fprintf('  Net work out          = %9.3f kJ/kg\n', w_net);
fprintf('  Boiler heat in        = %9.3f kJ/kg\n', q_in);
fprintf('  Condenser heat out    = %9.3f kJ/kg\n', q_out);
fprintf('  Back-work ratio       = %9.5f\n', bwr);
fprintf('  Thermal efficiency    = %9.4f  (%.2f%%)\n', eta_thermal, eta_thermal*100);
fprintf('  Carnot (ref) eff.     = %9.4f  (%.2f%%)\n', eta_carnot, eta_carnot*100);
fprintf('  Turbine exit quality  = %9.4f\n', x4);
fprintf('  Energy balance resid  = %9.3e kJ/kg (should be ~0)\n', energy_balance);
fprintf('\n');

if x4 < 0.85
    fprintf('  WARNING: exit quality below ~0.85, blade erosion risk.\n');
    fprintf('           Consider reheat to raise quality.\n\n');
end

%% SECTION 5: T-S DIAGRAM (state points connected)
% A full saturation dome needs the complete sat table. Here we plot the
% cycle path through the four state points, which is enough to see the
% shape. Temperatures in degC, entropies in kJ/(kg*K).
s_pts = [s1, s2, s3, s4, s1];
T_pts = [T1, T2, T3, T4, T1];

figure('Name','Rankine Cycle T-S Diagram','Color','w');
plot(s_pts, T_pts, 'r-', 'LineWidth', 2); hold on;
plot([s1 s2 s3 s4], [T1 T2 T3 T4], 'bo', ...
     'MarkerFaceColor', 'b', 'MarkerSize', 8);
labels = {'1','2','3','4'};
for i = 1:4
    sx = [s1 s2 s3 s4]; tx = [T1 T2 T3 T4];
    text(sx(i), tx(i), ['  ' labels{i}], 'FontSize', 12, 'FontWeight', 'bold');
end
xlabel('Entropy s [kJ/(kg*K)]');
ylabel('Temperature T [degC]');
title('Rankine Cycle: T-S Diagram (state-point path)');
grid on; hold off;

fprintf('Plot generated. Rankine cycle model complete.\n');
%% END OF RANKINE CYCLE MODEL
