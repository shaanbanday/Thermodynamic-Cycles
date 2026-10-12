// ========================================================================
//  RANKINE CYCLE MODEL (ideal, basic)  -- Scilab port
//  Working fluid: water/steam, enthalpy-based (NOT ideal-gas air).
//    1->2 isentropic pump; 2->3 const-P boiler heat in (superheat);
//    3->4 isentropic turbine; 4->1 const-P condenser heat out.
//  PROPERTY VALUES below are standard steam-table values for the chosen
//  conditions. VERIFY against your own reference.
// ========================================================================

clear; clc; xdel(winsid());

// SECTION 1: CYCLE CONDITIONS
P_boiler = 8000;    // boiler pressure                [kPa]
T_boiler = 480;     // turbine inlet (superheat) temp [degC]
P_cond   = 10;      // condenser pressure             [kPa]

mprintf("==================================================\n");
mprintf("  RANKINE CYCLE CONDITIONS\n");
mprintf("==================================================\n");
mprintf("  Boiler pressure       = %8.1f kPa\n", P_boiler);
mprintf("  Turbine inlet temp    = %8.1f degC\n", T_boiler);
mprintf("  Condenser pressure    = %8.1f kPa\n", P_cond);
mprintf("\n");

// SECTION 2: STEAM PROPERTIES  (VERIFY AGAINST YOUR TABLES)
hf_cond  = 191.83;      // sat liquid enthalpy        [kJ/kg]
vf_cond  = 0.001010;    // sat liquid specific volume [m^3/kg]
sf_cond  = 0.6493;      // sat liquid entropy         [kJ/(kg*K)]
hfg_cond = 2392.8;      // enthalpy of vaporization   [kJ/kg]
sfg_cond = 7.5009;      // entropy of vaporization    [kJ/(kg*K)]
Tsat_cond = 45.81;      // saturation temperature     [degC]

h3 = 3348.4;            // turbine inlet enthalpy     [kJ/kg]
s3 = 6.6586;            // turbine inlet entropy      [kJ/(kg*K)]

// SECTION 3: STATE POINTS
h1 = hf_cond; s1 = sf_cond; v1 = vf_cond; T1 = Tsat_cond;

w_pump = v1 * (P_boiler - P_cond);     // kPa*m^3/kg = kJ/kg
h2 = h1 + w_pump; s2 = s1; T2 = T1;

T3 = T_boiler;                          // h3, s3 from property block

s4 = s3;
x4 = (s4 - sf_cond) / sfg_cond;
h4 = hf_cond + x4 * hfg_cond;
T4 = Tsat_cond;

mprintf("==================================================\n");
mprintf("  STATE POINTS\n");
mprintf("==================================================\n");
mprintf("  State    h [kJ/kg]   s [kJ/(kg*K)]   T [degC]   note\n");
mprintf("  ------------------------------------------------------\n");
mprintf("    1     %9.2f     %8.4f     %7.2f   sat liquid\n", h1, s1, T1);
mprintf("    2     %9.2f     %8.4f     %7.2f   comp liquid\n", h2, s2, T2);
mprintf("    3     %9.2f     %8.4f     %7.2f   superheated\n", h3, s3, T3);
mprintf("    4     %9.2f     %8.4f     %7.2f   x = %5.4f\n", h4, s4, T4, x4);
mprintf("\n");

// SECTION 4: WORK, HEAT, EFFICIENCY
w_turbine = h3 - h4;
w_net     = w_turbine - w_pump;
q_in      = h3 - h2;
q_out     = h4 - h1;
eta_thermal = w_net / q_in;
bwr         = w_pump / w_turbine;
energy_balance = (q_in - q_out) - w_net;
eta_carnot = 1 - (Tsat_cond + 273.15) / (T_boiler + 273.15);

mprintf("==================================================\n");
mprintf("  WORK, HEAT, EFFICIENCY  (per kg of steam)\n");
mprintf("==================================================\n");
mprintf("  Pump work in          = %9.3f kJ/kg\n", w_pump);
mprintf("  Turbine work out      = %9.3f kJ/kg\n", w_turbine);
mprintf("  Net work out          = %9.3f kJ/kg\n", w_net);
mprintf("  Boiler heat in        = %9.3f kJ/kg\n", q_in);
mprintf("  Condenser heat out    = %9.3f kJ/kg\n", q_out);
mprintf("  Back-work ratio       = %9.5f\n", bwr);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_thermal, eta_thermal*100);
mprintf("  Carnot (ref) eff.     = %9.4f  (%.2f%%)\n", eta_carnot, eta_carnot*100);
mprintf("  Turbine exit quality  = %9.4f\n", x4);
mprintf("  Energy balance resid  = %9.3e kJ/kg (should be ~0)\n", energy_balance);
mprintf("\n");

if x4 < 0.85 then
    mprintf("  WARNING: exit quality below ~0.85, blade erosion risk.\n");
    mprintf("           Consider reheat to raise quality.\n\n");
end

// SECTION 5: T-S DIAGRAM (state-point path; full dome needs sat table)
s_pts = [s1, s2, s3, s4, s1];
T_pts = [T1, T2, T3, T4, T1];

scf(0);
plot(s_pts, T_pts, "r-", "LineWidth", 2);
plot([s1 s2 s3 s4], [T1 T2 T3 T4], "bo", ..
     "MarkerFaceColor", "blue", "MarkerSize", 8);
sx = [s1 s2 s3 s4]; tx = [T1 T2 T3 T4];
for i = 1:4
    xstring(sx(i), tx(i), msprintf("  %d", i));
end
xlabel("Entropy s [kJ/(kg*K)]");
ylabel("Temperature T [degC]");
title("Rankine Cycle: T-S Diagram (state-point path)");
xgrid();

mprintf("Plot generated. Rankine cycle model complete.\n");
// END OF RANKINE CYCLE MODEL
