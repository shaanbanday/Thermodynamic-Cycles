// ========================================================================
//  CARNOT CYCLE MODEL  (Scilab port)
//  Repository: thermodynamic-cycles
//  Working fluid: ideal gas (air, air-standard assumptions)
//
//  Four reversible processes:
//     1 -> 2 : Isothermal expansion   (heat added at T_hot)
//     2 -> 3 : Isentropic expansion   (T_hot -> T_cold)
//     3 -> 4 : Isothermal compression (heat rejected at T_cold)
//     4 -> 1 : Isentropic compression (T_cold -> T_hot)
//
//  Heat transfer only at the two temperature extremes, so this cycle
//  reaches the maximum possible efficiency for the given reservoirs.
// ========================================================================

clear;              // remove all variables
clc;                // clear the console
xdel(winsid());     // close all open graphics windows (safe if none open)

// ------------------------------------------------------------------------
//  SECTION 1: WORKING FLUID PROPERTIES (AIR, IDEAL GAS)
// ------------------------------------------------------------------------

R     = 287;                // specific gas constant for air   [J/(kg*K)]
gamma = 1.4;                // ratio of specific heats cp/cv    [-]
cv    = R / (gamma - 1);    // constant-volume specific heat    [J/(kg*K)]
cp    = gamma * cv;         // constant-pressure specific heat  [J/(kg*K)]

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

m       = 1.0;              // mass of working fluid            [kg]
T_hot   = 800;              // hot reservoir temperature        [K]
T_cold  = 300;              // cold reservoir temperature       [K]

P1      = 1000e3;                   // pressure at state 1       [Pa]
V1      = m * R * T_hot / P1;       // volume at state 1         [m^3]

r_iso   = 2.0;              // isothermal expansion ratio V2/V1 [-]

mprintf("==================================================\n");
mprintf("  CYCLE INPUT PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Mass m                = %8.3f kg\n", m);
mprintf("  Hot temperature T_hot = %8.3f K\n", T_hot);
mprintf("  Cold temperature      = %8.3f K\n", T_cold);
mprintf("  Pressure at state 1   = %8.3f kPa\n", P1/1000);
mprintf("  Volume at state 1     = %8.6f m^3\n", V1);
mprintf("  Isothermal vol ratio  = %8.3f\n", r_iso);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 3: STATE POINT CALCULATIONS  (1 -> 2 -> 3 -> 4 -> 1)
// ------------------------------------------------------------------------

// ----- STATE 1 -----
T1 = T_hot;                 // isothermal expansion runs at T_hot

// ----- STATE 2: end of isothermal expansion (1 -> 2) -----
T2 = T_hot;                 // constant along an isotherm
V2 = r_iso * V1;            // volume expands by the chosen ratio
P2 = m * R * T2 / V2;       // ideal gas law

// ----- STATE 3: end of isentropic expansion (2 -> 3) -----
T3 = T_cold;
// Isentropic: T * V^(gamma-1) = constant  ->  V3 = V2*(T2/T3)^(1/(gamma-1))
V3 = V2 * (T2 / T3)^(1 / (gamma - 1));
P3 = m * R * T3 / V3;

// ----- STATE 4: end of isothermal compression (3 -> 4) -----
T4 = T_cold;
// Fix V4 by working backwards through the isentropic leg 4 -> 1, so the
// cycle closes exactly: T4 * V4^(gamma-1) = T1 * V1^(gamma-1)
V4 = V1 * (T1 / T4)^(1 / (gamma - 1));
P4 = m * R * T4 / V4;

P_states = [P1, P2, P3, P4];    // [Pa]
V_states = [V1, V2, V3, V4];    // [m^3]
T_states = [T1, T2, T3, T4];    // [K]

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
//  SECTION 4: HEAT AND WORK FOR EACH PROCESS
// ------------------------------------------------------------------------

// 1 -> 2 isothermal expansion: Q = W = m*R*T*ln(V2/V1)
W_12 = m * R * T_hot * log(V2 / V1);    // work out  [J]
Q_12 = W_12;                             // Q = W      [J]

// 2 -> 3 isentropic expansion: Q = 0, W = -dU
Q_23 = 0;
W_23 = m * cv * (T2 - T3);

// 3 -> 4 isothermal compression: Q = W (both negative)
W_34 = m * R * T_cold * log(V4 / V3);
Q_34 = W_34;

// 4 -> 1 isentropic compression: Q = 0, W = -dU (negative)
Q_41 = 0;
W_41 = m * cv * (T4 - T1);

Q_processes = [Q_12, Q_23, Q_34, Q_41]; // [J]
W_processes = [W_12, W_23, W_34, W_41]; // [J]
labels = ["1->2 iso-T exp"; "2->3 isentropic exp"; ..
          "3->4 iso-T comp"; "4->1 isentropic comp"];

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
//  SECTION 5: CYCLE TOTALS AND EFFICIENCY
// ------------------------------------------------------------------------

Q_in    = Q_12;                 // heat added (only 1->2)   [J]
Q_out   = abs(Q_34);            // heat rejected (magnitude)[J]
W_net   = sum(W_processes);     // net work out             [J]

eta_cycle  = W_net / Q_in;              // thermal efficiency
eta_carnot = 1 - (T_cold / T_hot);      // Carnot limit
energy_balance = (Q_in - Q_out) - W_net; // should be ~0 [J]

mprintf("==================================================\n");
mprintf("  CYCLE TOTALS AND EFFICIENCY\n");
mprintf("==================================================\n");
mprintf("  Heat added Q_in       = %9.3f kJ\n", Q_in/1000);
mprintf("  Heat rejected Q_out   = %9.3f kJ\n", Q_out/1000);
mprintf("  Net work W_net        = %9.3f kJ\n", W_net/1000);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_cycle, eta_cycle*100);
mprintf("  Carnot efficiency     = %9.4f  (%.2f%%)\n", eta_carnot, eta_carnot*100);
mprintf("  Energy balance resid  = %9.3e kJ (should be ~0)\n", energy_balance/1000);
mprintf("\n");

if abs(eta_cycle - eta_carnot) < 1e-6 then
    mprintf("  CHECK PASSED: cycle efficiency matches Carnot limit.\n");
else
    mprintf("  CHECK FAILED: efficiency does not match Carnot limit.\n");
end
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 6: SMOOTH PROCESS CURVES FOR PLOTTING
// ------------------------------------------------------------------------

N = 100;    // points per process segment

// 1 -> 2 isothermal (P*V = const, T = T_hot)
V_12 = linspace(V1, V2, N);
P_12 = m * R * T1 ./ V_12;
T_12 = T1 * ones(1, N);

// 2 -> 3 isentropic (P*V^gamma = const)
V_23 = linspace(V2, V3, N);
P_23 = P2 * (V2 ./ V_23).^gamma;
T_23 = P_23 .* V_23 / (m * R);

// 3 -> 4 isothermal (T = T_cold)
V_34 = linspace(V3, V4, N);
P_34 = m * R * T3 ./ V_34;
T_34 = T3 * ones(1, N);

// 4 -> 1 isentropic
V_41 = linspace(V4, V1, N);
P_41 = P4 * (V4 ./ V_41).^gamma;
T_41 = P_41 .* V_41 / (m * R);

V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];

// ------------------------------------------------------------------------
//  SECTION 7: ENTROPY VALUES FOR THE T-S DIAGRAM
// ------------------------------------------------------------------------

s1 = 0;                           // reference entropy at state 1 [J/(kg*K)]
s2 = s1 + R * log(V2 / V1);       // 1->2 isothermal
s3 = s2;                          // 2->3 isentropic
s4 = s3 + R * log(V4 / V3);       // 3->4 isothermal (negative)

s_states = [s1, s2, s3, s4];
s_TS = [s1, s2, s3, s4, s1];      // close the loop
T_TS = [T1, T2, T3, T4, T1];

// ------------------------------------------------------------------------
//  SECTION 8: PLOTTING
//  Scilab overlays successive plot() calls on the current axes, so no
//  hold command is needed. Marker options below work on recent Scilab;
//  on older versions set them through the handle from gce().
// ------------------------------------------------------------------------

// ----- Figure 1: P-V diagram -----
scf(0);
plot(V_curve, P_curve/1000, "b-", "LineWidth", 2);
plot(V_states, P_states/1000, "ro", "MarkerFaceColor", "red", "MarkerSize", 8);
for i = 1:4
    xstring(V_states(i), P_states(i)/1000, msprintf("  %d", i));
end
xlabel("Volume V [m^3]");
ylabel("Pressure P [kPa]");
title("Carnot Cycle: P-V Diagram");
xgrid();

// ----- Figure 2: T-S diagram -----
scf(1);
plot(s_TS, T_TS, "r-", "LineWidth", 2);
plot(s_states, T_states, "bo", "MarkerFaceColor", "blue", "MarkerSize", 8);
for i = 1:4
    xstring(s_states(i), T_states(i), msprintf("  %d", i));
end
xlabel("Entropy change s [J/(kg*K)]");
ylabel("Temperature T [K]");
title("Carnot Cycle: T-S Diagram (rectangle)");
xgrid();

mprintf("Plots generated. Carnot cycle model complete.\n");

// ========================================================================
//  END OF CARNOT CYCLE MODEL
// ========================================================================
