// ========================================================================
//  BRAYTON (JOULE) CYCLE MODEL  (Scilab port)
//  Repository: thermodynamic-cycles
//  Working fluid: ideal gas (air, air-standard, cold-air assumptions)
//
//  Gas-turbine idealization, steady flow (cp basis). Four processes:
//     1 -> 2 : Isentropic compression
//     2 -> 3 : Constant-pressure heat addition
//     3 -> 4 : Isentropic expansion
//     4 -> 1 : Constant-pressure heat rejection
//
//  eta = 1 - 1/rp^((gamma-1)/gamma)
// ========================================================================

clear;
clc;
xdel(winsid());

// ------------------------------------------------------------------------
//  SECTION 1: WORKING FLUID PROPERTIES (AIR, IDEAL GAS)
// ------------------------------------------------------------------------

R     = 287;
gamma = 1.4;
cv    = R / (gamma - 1);
cp    = gamma * cv;

mprintf("==================================================\n");
mprintf("  WORKING FLUID PROPERTIES (air, ideal gas)\n");
mprintf("==================================================\n");
mprintf("  Gas constant R        = %8.3f J/(kg*K)\n", R);
mprintf("  Specific heat ratio   = %8.3f\n", gamma);
mprintf("  cv                    = %8.3f J/(kg*K)\n", cv);
mprintf("  cp                    = %8.3f J/(kg*K)\n", cp);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 2: CYCLE INPUT PARAMETERS
// ------------------------------------------------------------------------

m     = 1.0;
T1    = 300;
P1    = 100e3;
rp    = 10.0;
T3    = 1400;

pexp  = (gamma - 1) / gamma;
V1    = m * R * T1 / P1;

mprintf("==================================================\n");
mprintf("  CYCLE INPUT PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Mass basis m          = %8.3f kg\n", m);
mprintf("  Inlet temperature T1  = %8.3f K\n", T1);
mprintf("  Inlet pressure P1     = %8.3f kPa\n", P1/1000);
mprintf("  Pressure ratio rp     = %8.3f\n", rp);
mprintf("  Turbine inlet T3      = %8.3f K\n", T3);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
// ------------------------------------------------------------------------

// STATE 2: isentropic compression
P2 = rp * P1;
T2 = T1 * rp^pexp;
V2 = m * R * T2 / P2;

// STATE 3: constant-pressure heat addition
P3 = P2;
V3 = m * R * T3 / P3;

// STATE 4: isentropic expansion back to inlet pressure
P4 = P1;
T4 = T3 * (1 / rp)^pexp;
V4 = m * R * T4 / P4;

P_states = [P1, P2, P3, P4];
V_states = [V1, V2, V3, V4];
T_states = [T1, T2, T3, T4];

mprintf("==================================================\n");
mprintf("  STATE POINTS\n");
mprintf("==================================================\n");
mprintf("  State    P [kPa]     V [m^3]      T [K]\n");
mprintf("  --------------------------------------------\n");
for i = 1:4
    mprintf("    %d    %9.2f   %9.6f   %8.2f\n", ..
            i, P_states(i)/1000, V_states(i), T_states(i));
end
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 4: HEAT AND WORK PER PROCESS (STEADY FLOW, cp BASIS)
// ------------------------------------------------------------------------

Q_12 = 0;                        // compressor
W_12 = m * cp * (T1 - T2);

Q_23 = m * cp * (T3 - T2);       // combustor
W_23 = 0;

Q_34 = 0;                        // turbine
W_34 = m * cp * (T3 - T4);

Q_41 = m * cp * (T1 - T4);       // exhaust
W_41 = 0;

Q_processes = [Q_12, Q_23, Q_34, Q_41];
W_processes = [W_12, W_23, W_34, W_41];
labels = ["1->2 compressor"; "2->3 const-P heat in"; ..
          "3->4 turbine"; "4->1 const-P heat out"];

mprintf("==================================================\n");
mprintf("  HEAT AND WORK PER PROCESS\n");
mprintf("==================================================\n");
mprintf("  Process                    Q [kJ]      W [kJ]\n");
mprintf("  ------------------------------------------------\n");
for i = 1:4
    mprintf("  %-22s  %9.3f   %9.3f\n", ..
            labels(i), Q_processes(i)/1000, W_processes(i)/1000);
end
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 5: CYCLE TOTALS, EFFICIENCY, BACK-WORK RATIO
// ------------------------------------------------------------------------

W_comp  = abs(W_12);
W_turb  = W_34;
Q_out   = abs(Q_41);
W_net   = sum(W_processes);
eta_cycle = W_net / Q_23;
eta_ideal = 1 - 1 / rp^pexp;
bwr     = W_comp / W_turb;
energy_balance = (Q_23 - Q_out) - W_net;

mprintf("==================================================\n");
mprintf("  CYCLE TOTALS AND EFFICIENCY\n");
mprintf("==================================================\n");
mprintf("  Compressor work in    = %9.3f kJ\n", W_comp/1000);
mprintf("  Turbine work out      = %9.3f kJ\n", W_turb/1000);
mprintf("  Heat added Q_in       = %9.3f kJ\n", Q_23/1000);
mprintf("  Heat rejected Q_out   = %9.3f kJ\n", Q_out/1000);
mprintf("  Net work W_net        = %9.3f kJ\n", W_net/1000);
mprintf("  Back-work ratio       = %9.4f\n", bwr);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_cycle, eta_cycle*100);
mprintf("  Ideal Brayton eff.    = %9.4f  (%.2f%%)\n", eta_ideal, eta_ideal*100);
mprintf("  Energy balance resid  = %9.3e kJ (should be ~0)\n", energy_balance/1000);
mprintf("\n");

if abs(eta_cycle - eta_ideal) < 1e-6 then
    mprintf("  CHECK PASSED: efficiency matches air-standard Brayton formula.\n");
else
    mprintf("  CHECK FAILED: efficiency does not match formula.\n");
end
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 6: SMOOTH PROCESS CURVES FOR PLOTTING
// ------------------------------------------------------------------------

N = 100;

// 1 -> 2 isentropic
V_12 = linspace(V1, V2, N);
P_12 = P1 * (V1 ./ V_12).^gamma;

// 2 -> 3 constant pressure
V_23 = linspace(V2, V3, N);
P_23 = P2 * ones(1, N);

// 3 -> 4 isentropic
V_34 = linspace(V3, V4, N);
P_34 = P3 * (V3 ./ V_34).^gamma;

// 4 -> 1 constant pressure
V_41 = linspace(V4, V1, N);
P_41 = P4 * ones(1, N);

V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];

// ------------------------------------------------------------------------
//  SECTION 7: ENTROPY VALUES FOR THE T-S DIAGRAM
// ------------------------------------------------------------------------

s1 = 0;
s2 = s1;                          // 1->2 isentropic
s3 = s2 + cp * log(T3 / T2);      // 2->3 constant pressure
s4 = s3;                          // 3->4 isentropic

s_states = [s1, s2, s3, s4];

T_23s = linspace(T2, T3, N);
s_23s = s2 + cp * log(T_23s / T2);
T_41s = linspace(T4, T1, N);
s_41s = s4 + cp * log(T_41s / T4);

s_TS = [s1, s2, s_23s, s3, s4, s_41s, s1];
T_TS = [T1, T2, T_23s, T3, T4, T_41s, T1];

// ------------------------------------------------------------------------
//  SECTION 8: PLOTTING
// ------------------------------------------------------------------------

scf(0);
plot(V_curve, P_curve/1000, "b-", "LineWidth", 2);
plot(V_states, P_states/1000, "ro", "MarkerFaceColor", "red", "MarkerSize", 8);
for i = 1:4
    xstring(V_states(i), P_states(i)/1000, msprintf("  %d", i));
end
xlabel("Specific volume v [m^3/kg]");
ylabel("Pressure P [kPa]");
title("Brayton Cycle: P-V Diagram");
xgrid();

scf(1);
plot(s_TS, T_TS, "r-", "LineWidth", 2);
plot(s_states, T_states, "bo", "MarkerFaceColor", "blue", "MarkerSize", 8);
for i = 1:4
    xstring(s_states(i), T_states(i), msprintf("  %d", i));
end
xlabel("Entropy change s [J/(kg*K)]");
ylabel("Temperature T [K]");
title("Brayton Cycle: T-S Diagram");
xgrid();

mprintf("Plots generated. Brayton cycle model complete.\n");

// ========================================================================
//  END OF BRAYTON CYCLE MODEL
// ========================================================================
