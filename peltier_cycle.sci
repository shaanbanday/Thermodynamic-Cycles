// ========================================================================
//  PELTIER (THERMOELECTRIC) COOLER MODEL  -- Scilab port
//  Not a fluid cycle. Current I pumps heat from Tc to Th.
//    Q_c = alpha*I*Tc - 0.5*I^2*R - K*(Th-Tc)
//    Q_h = alpha*I*Th + 0.5*I^2*R - K*(Th-Tc)
//    P   = alpha*I*(Th-Tc) + I^2*R,   COP = Q_c/P
//    ZT  = alpha^2 * T_avg / (R*K)
// ========================================================================

clear; clc; xdel(winsid());

// SECTION 1: MODULE PARAMETERS
alpha = 0.0530; R = 2.10; K = 0.470;
Tc = 273.15; Th = 300.15;
dT = Th - Tc; T_avg = 0.5*(Th + Tc);
ZT = alpha^2 * T_avg / (R * K);

mprintf("==================================================\n");
mprintf("  THERMOELECTRIC MODULE PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Seebeck coefficient   = %8.4f V/K\n", alpha);
mprintf("  Electrical resistance = %8.4f ohm\n", R);
mprintf("  Thermal conductance   = %8.4f W/K\n", K);
mprintf("  Cold-side temp Tc     = %8.2f K\n", Tc);
mprintf("  Hot-side temp Th      = %8.2f K\n", Th);
mprintf("  Temperature diff dT   = %8.2f K\n", dT);
mprintf("  Figure of merit ZT    = %8.4f\n", ZT);
mprintf("\n");

// SECTION 2: KEY OPERATING CURRENTS
I_maxQc  = alpha * Tc / R;
I_optCOP = alpha * dT / (R * (sqrt(1 + ZT) - 1));
dT_max   = 0.5 * ZT * Tc^2 / T_avg;

mprintf("==================================================\n");
mprintf("  KEY OPERATING CURRENTS\n");
mprintf("==================================================\n");
mprintf("  I for max cooling Qc  = %8.3f A\n", I_maxQc);
mprintf("  I for max COP         = %8.3f A\n", I_optCOP);
mprintf("  Approx dT_max (Qc=0)  = %8.3f K\n", dT_max);
mprintf("\n");

// SECTION 3: PERFORMANCE AT KEY CURRENTS
currents = [I_maxQc, I_optCOP];
names    = ["max cooling"; "max COP"];
mprintf("==================================================\n");
mprintf("  PERFORMANCE AT KEY CURRENTS\n");
mprintf("==================================================\n");
mprintf("  Operating point   I [A]    Qc [W]    P [W]    COP\n");
mprintf("  ----------------------------------------------------\n");
for i = 1:2
    I   = currents(i);
    Qc  = alpha*I*Tc - 0.5*I^2*R - K*dT;
    P   = alpha*I*dT + I^2*R;
    COP = Qc / P;
    mprintf("  %-14s  %7.3f  %8.3f  %7.3f  %6.4f\n", ..
            names(i), I, Qc, P, COP);
end
mprintf("\n");

// SECTION 4: SWEEP CURRENT
N = 300;
I_sweep  = linspace(0.01, 1.4 * I_maxQc, N);
Qc_sweep = alpha .* I_sweep .* Tc - 0.5 .* I_sweep.^2 .* R - K*dT;
Qh_sweep = alpha .* I_sweep .* Th + 0.5 .* I_sweep.^2 .* R - K*dT;
P_sweep  = alpha .* I_sweep .* dT + I_sweep.^2 .* R;
COP_sweep = Qc_sweep ./ P_sweep;
COP_sweep(Qc_sweep < 0) = 0;

// SECTION 5: PLOTTING
scf(0);
plot(I_sweep, Qc_sweep, "b-", "LineWidth", 2);
plot(I_sweep, P_sweep,  "r-", "LineWidth", 2);
plot(I_sweep, Qh_sweep, "k--", "LineWidth", 1.5);
legend(["Q_c cooling power"; "P electrical in"; "Q_h heat rejected"], 2);
xlabel("Current I [A]");
ylabel("Power [W]");
title("Peltier Module: Power vs Current");
xgrid();

scf(1);
plot(I_sweep, COP_sweep, "m-", "LineWidth", 2);
legend(["COP (cooling)"], 1);
xlabel("Current I [A]");
ylabel("COP [-]");
title("Peltier Module: Cooling COP vs Current");
xgrid();

mprintf("Plots generated. Peltier model complete.\n");
// END OF PELTIER MODEL
