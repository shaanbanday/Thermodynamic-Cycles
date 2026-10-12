// ========================================================================
//  CHENG CYCLE MODEL  (SCAFFOLD -- steam-injected gas turbine / STIG)
//  Repository: thermodynamic-cycles
//
//  A Brayton gas turbine with steam raised in a heat-recovery steam
//  generator (HRSG) from the exhaust, then injected into the combustor.
//  The injected steam adds mass flow through the turbine, raising power
//  and efficiency without a separate steam turbine.
//
//  PROPERTY DEPENDENCY: combustion-gas properties (cp varies with T and
//  composition) AND steam enthalpy. The air-side can start from cold-air
//  Brayton (see brayton.sce), but the HRSG and injection need real steam
//  enthalpies and a gas-side cp that reflects the combustion products.
//  Fill the marked values; the air-standard pieces are pre-filled as a
//  starting point you should refine.
//
//  Air side (Brayton core):   1 compressor in -> 2 compressor out ->
//    3 combustor out (turbine in) -> 4 turbine out -> HRSG -> stack
//  Steam side:  w1 feedwater -> w2 pump out -> w3 HRSG steam out ->
//    injected at combustor
// ========================================================================

clear; clc; xdel(winsid());

// ------------------------------------------------------------------------
//  SECTION 1: AIR-SIDE PARAMETERS  (cold-air Brayton starting point)
// ------------------------------------------------------------------------
R     = 287;  gamma = 1.4;  cp_air = gamma*R/(gamma-1);   // J/(kg*K)
T1    = 300;        // compressor inlet            [K]
P1    = 100e3;      // compressor inlet            [Pa]
rp    = 12.0;       // pressure ratio              [-]
T3    = 1500;       // turbine inlet temperature   [K]
m_air = 1.0;        // air mass flow               [kg/s]
pexp  = (gamma-1)/gamma;

// ------------------------------------------------------------------------
//  SECTION 2: STEAM-SIDE PROPERTIES  <<< FILL THESE >>>
//  From steam tables at the injection pressure (~ combustor pressure).
// ------------------------------------------------------------------------
m_steam = 0.10;     // injected steam / air mass ratio basis [kg/s]  (design)
hw_feed = %nan;     // feedwater enthalpy                    [kJ/kg]
hw_steam = %nan;    // superheated steam enthalpy at injection P,T [kJ/kg]
cp_gas  = 1.15e3;   // combustion-gas cp estimate (REFINE)   [J/(kg*K)]
h_steam_at_T3 = %nan;  // steam enthalpy carried to turbine inlet T3 [kJ/kg]

mprintf("==================================================\n");
mprintf("  CHENG (STIG) CYCLE CONDITIONS\n");
mprintf("==================================================\n");
mprintf("  Pressure ratio        = %8.2f\n", rp);
mprintf("  Turbine inlet T3      = %8.1f K\n", T3);
mprintf("  Steam injection ratio = %8.3f kg steam / kg air\n", m_steam/m_air);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 3: AIR-SIDE STATE POINTS  (Brayton core, correct as-is)
// ------------------------------------------------------------------------
T2 = T1 * rp^pexp;          // compressor outlet
T4 = T3 * (1/rp)^pexp;      // turbine outlet (air-standard estimate)

w_comp = m_air * cp_air * (T2 - T1);       // W
// Turbine now processes air + injected steam. Air part:
w_turb_air = m_air * cp_air * (T3 - T4);   // W

mprintf("  Air-side: T2 = %7.2f K, T4 = %7.2f K\n", T2, T4);
mprintf("  Compressor work = %9.3f kW\n", w_comp/1000);
mprintf("  Turbine work (air part only) = %9.3f kW\n", w_turb_air/1000);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 4: STEAM CONTRIBUTION + TOTALS  <<< needs filled steam props >>>
// ------------------------------------------------------------------------
// Extra turbine work from the steam expanding with the gas (needs real
// steam enthalpy drop across the turbine):
w_turb_steam = m_steam * (h_steam_at_T3 - hw_steam);   // kW-ish, fill props
// Fuel heat in: raise combined stream to T3, plus make the steam:
q_fuel = m_air*cp_air*(T3 - T2)/1000 + m_steam*(hw_steam - hw_feed);  // kW
w_net  = w_turb_air/1000 + w_turb_steam - w_comp/1000;

eta_thermal = w_net / q_fuel;

mprintf("==================================================\n");
mprintf("  RESULTS  (NaN until steam block is filled)\n");
mprintf("==================================================\n");
mprintf("  Steam-side turbine work = %9.3f kW\n", w_turb_steam);
mprintf("  Fuel heat in            = %9.3f kW\n", q_fuel);
mprintf("  Net work                = %9.3f kW\n", w_net);
mprintf("  Thermal efficiency      = %9.4f\n", eta_thermal);
mprintf("\n");
if isnan(eta_thermal) then
    mprintf("  SCAFFOLD: fill Section 2 steam enthalpies to populate results.\n");
    mprintf("  Also refine cp_gas and T4 with real combustion-gas properties.\n");
end
// END OF CHENG CYCLE SCAFFOLD
