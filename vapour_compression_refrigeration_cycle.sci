// ========================================================================
//  VAPOUR-COMPRESSION REFRIGERATION CYCLE (ideal)  -- Scilab port
//  Working fluid: R-134a, enthalpy-based (NOT ideal-gas air).
//    1->2 isentropic compression; 2->3 const-P condenser (-> sat liq);
//    3->4 isenthalpic throttle; 4->1 const-P evaporator (-> sat vap).
//  COP_cool = q_evap/w_comp, COP_heat = q_cond/w_comp.
//  PROPERTY VALUES are standard R-134a table values; VERIFY, especially
//  the superheated h2 at (P_cond, s1).
// ========================================================================

clear; clc; xdel(winsid());

// SECTION 1: CYCLE CONDITIONS
T_evap = -20;   // evaporator temperature  [degC]
T_cond =  40;   // condenser temperature   [degC]

mprintf("==================================================\n");
mprintf("  VAPOUR-COMPRESSION CYCLE CONDITIONS (R-134a)\n");
mprintf("==================================================\n");
mprintf("  Evaporator temperature = %7.1f degC\n", T_evap);
mprintf("  Condenser temperature  = %7.1f degC\n", T_cond);
mprintf("\n");

// SECTION 2: R-134a PROPERTIES  (VERIFY AGAINST YOUR TABLES)
P_evap = 132.8; h1 = 238.43; s1 = 0.94565;   // state 1 sat vapour, -20 C
P_cond = 1017.0; h3 = 108.26;                // state 3 sat liquid, 40 C
h2 = 275.39;                                 // state 2 superheated, VERIFY

// SECTION 3: STATE POINTS
s2 = s1;
h4 = h3;                                     // isenthalpic throttle
h_states = [h1, h2, h3, h4];
P_states = [P_evap, P_cond, P_cond, P_evap];
mprintf("==================================================\n");
mprintf("  STATE POINTS\n");
mprintf("==================================================\n");
mprintf("  State    P [kPa]    h [kJ/kg]    note\n");
mprintf("  ------------------------------------------------\n");
mprintf("    1     %8.1f   %9.2f    sat vapour (evap out)\n", P_evap, h1);
mprintf("    2     %8.1f   %9.2f    superheated (comp out)\n", P_cond, h2);
mprintf("    3     %8.1f   %9.2f    sat liquid (cond out)\n", P_cond, h3);
mprintf("    4     %8.1f   %9.2f    two-phase (valve out)\n", P_evap, h4);
mprintf("\n");

// SECTION 4: WORK, HEAT, COP
w_comp = h2 - h1;
q_evap = h1 - h4;
q_cond = h2 - h3;
COP_cool = q_evap / w_comp;
COP_heat = q_cond / w_comp;
energy_balance = q_cond - (q_evap + w_comp);
Tc = T_evap + 273.15; Th = T_cond + 273.15;
COP_cool_carnot = Tc / (Th - Tc);

mprintf("==================================================\n");
mprintf("  WORK, HEAT, COP  (per kg of refrigerant)\n");
mprintf("==================================================\n");
mprintf("  Compressor work in    = %9.3f kJ/kg\n", w_comp);
mprintf("  Refrigeration effect  = %9.3f kJ/kg\n", q_evap);
mprintf("  Heat rejected         = %9.3f kJ/kg\n", q_cond);
mprintf("  COP (cooling)         = %9.4f\n", COP_cool);
mprintf("  COP (heating)         = %9.4f\n", COP_heat);
mprintf("  Carnot COP (cooling)  = %9.4f  (upper bound)\n", COP_cool_carnot);
mprintf("  Energy balance resid  = %9.3e kJ/kg (should be ~0)\n", energy_balance);
mprintf("\n");

// SECTION 5: P-h DIAGRAM (log pressure axis)
h_path = [h1, h2, h3, h4, h1];
P_path = [P_evap, P_cond, P_cond, P_evap, P_evap];

scf(0);
plot(h_path, P_path, "b-", "LineWidth", 2);
plot(h_states, P_states, "ro", "MarkerFaceColor", "red", "MarkerSize", 8);
for i = 1:4
    xstring(h_states(i), P_states(i), msprintf("  %d", i));
end
a = gca(); a.y_location = "left"; a.log_flags = "nln";  // log P axis
xlabel("Enthalpy h [kJ/kg]");
ylabel("Pressure P [kPa] (log scale)");
title("Vapour-Compression Cycle: P-h Diagram");
xgrid();

mprintf("Plot generated. Vapour-compression model complete.\n");
// END OF VAPOUR-COMPRESSION MODEL
