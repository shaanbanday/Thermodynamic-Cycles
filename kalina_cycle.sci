// ========================================================================
//  KALINA CYCLE MODEL  (SCAFFOLD -- fill property block before trusting)
//  Repository: thermodynamic-cycles
//  Working fluid: ammonia-water mixture (variable concentration)
//
//  The Kalina cycle uses a zeotropic NH3-H2O mixture whose boiling point
//  shifts as it evaporates, which matches the heat-source temperature
//  glide better than a pure fluid. A separator splits a strong (NH3-rich)
//  vapour from a weak liquid; the vapour drives the turbine, the streams
//  recombine, and a recuperator preheats before the boiler.
//
//  PROPERTY DEPENDENCY: mixture enthalpy h(T,P,x) and VLE for NH3-H2O.
//  There is NO clean closed form. Fill the state enthalpies below from a
//  mixture property source (e.g. CoolProp "REFPROP::AMMONIA[x]&WATER[1-x]"
//  or published NH3-H2O charts). Values left as NaN so nothing runs on
//  invented numbers.
//
//  Simplified state numbering (one common basic layout):
//    1 : pump inlet, saturated liquid (basic/weak mix) at low P
//    2 : pump outlet, high P
//    3 : recuperator cold-side outlet (preheated)
//    4 : separator feed / boiler outlet, two-phase
//    5 : strong vapour to turbine
//    6 : weak liquid from separator
//    7 : turbine outlet, low P
//    8 : mixture after recombination, condenser inlet
// ========================================================================

clear; clc; xdel(winsid());

// ------------------------------------------------------------------------
//  SECTION 1: CYCLE CONDITIONS  (edit to your design point)
// ------------------------------------------------------------------------
P_high   = 3000;     // high-side pressure            [kPa]
P_low    = 500;      // low-side pressure             [kPa]
x_basic  = 0.70;     // basic-solution NH3 mass frac  [-]
x_strong = 0.95;     // strong-vapour NH3 mass frac   [-]
x_weak   = 0.40;     // weak-liquid NH3 mass frac     [-]
m_total  = 1.0;      // total mass flow basis         [kg/s]

mprintf("==================================================\n");
mprintf("  KALINA CYCLE CONDITIONS (NH3-H2O)\n");
mprintf("==================================================\n");
mprintf("  High pressure         = %8.1f kPa\n", P_high);
mprintf("  Low pressure          = %8.1f kPa\n", P_low);
mprintf("  Basic NH3 frac        = %8.3f\n", x_basic);
mprintf("  Strong vapour frac    = %8.3f\n", x_strong);
mprintf("  Weak liquid frac      = %8.3f\n", x_weak);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 2: MIXTURE PROPERTIES  <<< FILL THESE >>>
//  Each enthalpy [kJ/kg] from your NH3-H2O source at the stated state.
//  Vapour fraction from the separator sets the stream split.
// ------------------------------------------------------------------------
h1 = %nan;     // sat liquid, basic mix, P_low
h2 = %nan;     // pump outlet, P_high  (or h1 + v*dP as an estimate)
h3 = %nan;     // recuperator cold outlet, P_high
h4 = %nan;     // boiler outlet / separator feed, two-phase, P_high
h5 = %nan;     // strong vapour from separator (x_strong), P_high
h6 = %nan;     // weak liquid from separator (x_weak), P_high
h7 = %nan;     // turbine outlet, P_low  (isentropic s7 = s5, then h7)
h8 = %nan;     // recombined mixture, condenser inlet, P_low

// Stream split from a mass + species balance across the separator:
//   m_total*x_basic = m_strong*x_strong + m_weak*x_weak
//   m_strong + m_weak = m_total
m_strong = m_total*(x_basic - x_weak)/(x_strong - x_weak);
m_weak   = m_total - m_strong;

mprintf("  Separator split: m_strong = %6.4f kg/s, m_weak = %6.4f kg/s\n\n", ..
        m_strong, m_weak);

// ------------------------------------------------------------------------
//  SECTION 3: WORK, HEAT, EFFICIENCY  (logic correct; needs h-values)
// ------------------------------------------------------------------------
w_pump    = m_total  * (h2 - h1);     // pump work in   [kW]
q_in      = m_total  * (h4 - h3);     // boiler heat in [kW]
w_turbine = m_strong * (h5 - h7);     // turbine work   [kW]
q_out     = m_total  * (h8 - h1);     // condenser out  [kW]  (approx layout)

w_net     = w_turbine - w_pump;
eta_thermal = w_net / q_in;

mprintf("==================================================\n");
mprintf("  RESULTS  (NaN until property block is filled)\n");
mprintf("==================================================\n");
mprintf("  Pump work in          = %9.3f kW\n", w_pump);
mprintf("  Turbine work out      = %9.3f kW\n", w_turbine);
mprintf("  Net work              = %9.3f kW\n", w_net);
mprintf("  Boiler heat in        = %9.3f kW\n", q_in);
mprintf("  Thermal efficiency    = %9.4f\n", eta_thermal);
mprintf("\n");

if isnan(eta_thermal) then
    mprintf("  SCAFFOLD: fill Section 2 enthalpies, then results populate.\n\n");
end

// ------------------------------------------------------------------------
//  SECTION 4: PLOTTING  (runs once h-values exist; guarded otherwise)
// ------------------------------------------------------------------------
if ~isnan(h1 + h2 + h3 + h4 + h5 + h7 + h8) then
    h_path = [h1, h2, h3, h4, h5, h7, h8, h1];
    idx    = 1:length(h_path);
    scf(0);
    plot(idx, h_path, "b-o", "LineWidth", 2);
    xlabel("State sequence");
    ylabel("Enthalpy h [kJ/kg]");
    title("Kalina Cycle: enthalpy around the loop");
    xgrid();
    mprintf("Plot generated. Kalina scaffold complete.\n");
else
    mprintf("Plot skipped (enthalpies not yet filled).\n");
end
// END OF KALINA CYCLE SCAFFOLD
