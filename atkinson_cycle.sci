// ========================================================================
//  ATKINSON CYCLE MODEL  (Scilab port)
//  Over-expanded SI cycle. Isentropic comp -> const-V heat in ->
//  isentropic expansion to P4=P1 -> const-P heat rejection.
//  eta = 1 - gamma*(lambda^(1/gamma)-1)/(r^(gamma-1)*(lambda-1))
// ========================================================================

clear; clc; xdel(winsid());

// SECTION 1: WORKING FLUID PROPERTIES
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

// SECTION 2: CYCLE INPUT PARAMETERS
m     = 1.0;
T1    = 300;
P1    = 100e3;
r     = 8.0;
q_in  = 800e3;
Q_in  = m * q_in;
V1    = m * R * T1 / P1;
V2    = V1 / r;

mprintf("==================================================\n");
mprintf("  CYCLE INPUT PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Mass m                = %8.3f kg\n", m);
mprintf("  State 1 temperature   = %8.3f K\n", T1);
mprintf("  State 1 pressure      = %8.3f kPa\n", P1/1000);
mprintf("  Compression ratio r   = %8.3f\n", r);
mprintf("  Heat added q_in       = %8.3f kJ/kg\n", q_in/1000);
mprintf("  Volume at state 1     = %8.6f m^3\n", V1);
mprintf("  Volume at state 2     = %8.6f m^3\n", V2);
mprintf("\n");

// SECTION 3: STATE POINT CALCULATIONS
T2 = T1 * r^(gamma - 1);
P2 = P1 * r^gamma;
V3 = V2;
T3 = T2 + Q_in / (m * cv);
P3 = m * R * T3 / V3;
lambda = T3 / T2;
P4 = P1;
V4 = V3 * (P3 / P4)^(1 / gamma);
T4 = T3 * (P4 / P3)^((gamma - 1) / gamma);

P_states = [P1, P2, P3, P4];
V_states = [V1, V2, V3, V4];
T_states = [T1, T2, T3, T4];

mprintf("==================================================\n");
mprintf("  STATE POINTS  (lambda = %6.4f, expansion V4/V2 = %6.4f)\n", ..
        lambda, V4/V2);
mprintf("==================================================\n");
mprintf("  State    P [kPa]     V [m^3]      T [K]\n");
mprintf("  --------------------------------------------\n");
for i = 1:4
    mprintf("    %d    %9.2f   %9.6f   %8.2f\n", ..
            i, P_states(i)/1000, V_states(i), T_states(i));
end
mprintf("\n");

// SECTION 4: HEAT AND WORK PER PROCESS
Q_12 = 0;                 W_12 = m * cv * (T1 - T2);
W_23 = 0;                 Q_23 = m * cv * (T3 - T2);
Q_34 = 0;                 W_34 = m * cv * (T3 - T4);
Q_41 = m * cp * (T1 - T4); W_41 = m * R  * (T1 - T4);

Q_processes = [Q_12, Q_23, Q_34, Q_41];
W_processes = [W_12, W_23, W_34, W_41];
labels = ["1->2 isentropic comp"; "2->3 const-V heat in"; ..
          "3->4 isentropic exp"; "4->1 const-P heat out"];

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

// SECTION 5: CYCLE TOTALS AND EFFICIENCY
Q_out   = abs(Q_41);
W_net   = sum(W_processes);
eta_cycle = W_net / Q_23;
eta_ideal = 1 - gamma * (lambda^(1/gamma) - 1) / (r^(gamma-1) * (lambda - 1));
energy_balance = (Q_23 - Q_out) - W_net;

mprintf("==================================================\n");
mprintf("  CYCLE TOTALS AND EFFICIENCY\n");
mprintf("==================================================\n");
mprintf("  Heat added Q_in       = %9.3f kJ\n", Q_23/1000);
mprintf("  Heat rejected Q_out   = %9.3f kJ\n", Q_out/1000);
mprintf("  Net work W_net        = %9.3f kJ\n", W_net/1000);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_cycle, eta_cycle*100);
mprintf("  Ideal Atkinson eff.   = %9.4f  (%.2f%%)\n", eta_ideal, eta_ideal*100);
mprintf("  Energy balance resid  = %9.3e kJ (should be ~0)\n", energy_balance/1000);
mprintf("\n");

if abs(eta_cycle - eta_ideal) < 1e-6 then
    mprintf("  CHECK PASSED: efficiency matches air-standard Atkinson formula.\n");
else
    mprintf("  CHECK FAILED: efficiency does not match formula.\n");
end
mprintf("\n");

// SECTION 6: SMOOTH PROCESS CURVES
N = 100;
V_12 = linspace(V1, V2, N);  P_12 = P1 * (V1 ./ V_12).^gamma;
P_23 = linspace(P2, P3, N);  V_23 = V2 * ones(1, N);
V_34 = linspace(V3, V4, N);  P_34 = P3 * (V3 ./ V_34).^gamma;
V_41 = linspace(V4, V1, N);  P_41 = P4 * ones(1, N);
V_curve = [V_12, V_23, V_34, V_41];
P_curve = [P_12, P_23, P_34, P_41];

// SECTION 7: ENTROPY VALUES
s1 = 0; s2 = s1; s3 = s2 + cv * log(T3 / T2); s4 = s3;
s_states = [s1, s2, s3, s4];
T_23s = linspace(T2, T3, N);  s_23s = s2 + cv * log(T_23s / T2);
T_41s = linspace(T4, T1, N);  s_41s = s4 + cp * log(T_41s / T4);
s_TS = [s1, s2, s_23s, s3, s4, s_41s, s1];
T_TS = [T1, T2, T_23s, T3, T4, T_41s, T1];

// SECTION 8: PLOTTING
scf(0);
plot(V_curve, P_curve/1000, "b-", "LineWidth", 2);
plot(V_states, P_states/1000, "ro", "MarkerFaceColor", "red", "MarkerSize", 8);
for i = 1:4
    xstring(V_states(i), P_states(i)/1000, msprintf("  %d", i));
end
xlabel("Volume V [m^3]"); ylabel("Pressure P [kPa]");
title("Atkinson Cycle: P-V Diagram"); xgrid();

scf(1);
plot(s_TS, T_TS, "r-", "LineWidth", 2);
plot(s_states, T_states, "bo", "MarkerFaceColor", "blue", "MarkerSize", 8);
for i = 1:4
    xstring(s_states(i), T_states(i), msprintf("  %d", i));
end
xlabel("Entropy change s [J/(kg*K)]"); ylabel("Temperature T [K]");
title("Atkinson Cycle: T-S Diagram"); xgrid();

mprintf("Plots generated. Atkinson cycle model complete.\n");
// END OF ATKINSON CYCLE MODEL
