// ========================================================================
//  CLAUDE LIQUEFACTION CYCLE  (SCAFFOLD -- REAL-GAS DATA REQUIRED)
//  Repository: thermodynamic-cycles
//  Working fluid: nitrogen (or air) -- REAL gas, not ideal
//
//  An improvement on Linde-Hampson: part of the high-pressure stream is
//  diverted through an EXPANDER (does work, cools strongly) instead of all
//  going through the JT valve. The expander provides most of the cooling,
//  so the cycle liquefies more per unit work. Same real-gas requirement:
//  without real enthalpies there is no Joule-Thomson effect and no
//  meaningful expander cooling to model.
//
//  Streams:
//    1 : makeup gas, ambient T, low P
//    2 : compressor out, high P, cooled to T_amb
//    3 : after first HX stage
//    e : fraction x diverted to expander -> cools -> rejoins return
//    4 : remaining (1-x) after final HX, into JT valve
//    5 : after JT valve, two-phase, low P
//    f : saturated liquid product;  g : saturated vapour return
//
//  Liquid yield (standard Claude result, from an energy balance):
//    y = (h1 - h2)/(h1 - hf) + x*(h3 - he)/(h1 - hf)
//  where x is the expander mass fraction and (h3 - he) is the expander
//  enthalpy drop. All h are REAL-gas enthalpies [kJ/kg].
//
//  PROPERTY DEPENDENCY: real-gas h(T,P) for N2. Fill from CoolProp/NIST.
// ========================================================================

clear; clc; xdel(winsid());

// ------------------------------------------------------------------------
//  SECTION 1: CYCLE CONDITIONS
// ------------------------------------------------------------------------
fluid  = "Nitrogen";
T_amb  = 300;        // ambient / aftercooler temperature   [K]
P_low  = 100e3;      // product / suction pressure          [Pa]
P_high = 4e6;        // discharge pressure (lower than Linde) [Pa]
x_exp  = 0.70;       // fraction of flow sent to expander    [-]
eta_exp = 0.80;      // expander isentropic efficiency       [-]

mprintf("==================================================\n");
mprintf("  CLAUDE LIQUEFACTION (%s)\n", fluid);
mprintf("==================================================\n");
mprintf("  Ambient temperature   = %8.1f K\n", T_amb);
mprintf("  Low pressure          = %8.1f kPa\n", P_low/1000);
mprintf("  High pressure         = %8.1f kPa\n", P_high/1000);
mprintf("  Expander fraction x   = %8.3f\n", x_exp);
mprintf("  Expander eff.         = %8.3f\n", eta_exp);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 2: REAL-GAS ENTHALPIES  <<< FILL THESE (CoolProp/NIST) >>>
//  h1 : gas at (T_amb, P_low)
//  h2 : gas at (T_amb, P_high)
//  h3 : gas entering the expander (T after first HX, P_high)
//  he : expander outlet (isentropic to P_low, then apply eta_exp)
//  hf : saturated liquid at P_low
// ------------------------------------------------------------------------
h1 = %nan;     // PropsSI("H","T",300,"P",1e5,"Nitrogen")/1000
h2 = %nan;     // PropsSI("H","T",300,"P",4e6,"Nitrogen")/1000
h3 = %nan;     // gas at expander inlet (set your intermediate T)
he_s = %nan;   // isentropic expander outlet enthalpy at P_low
hf = %nan;     // PropsSI("H","Q",0,"P",1e5,"Nitrogen")/1000

// Apply expander efficiency: actual drop = eta * ideal drop
he = h3 - eta_exp*(h3 - he_s);      // actual expander outlet enthalpy

// ------------------------------------------------------------------------
//  SECTION 3: LIQUID YIELD  (logic correct; needs h-values)
// ------------------------------------------------------------------------
y = (h1 - h2)/(h1 - hf) + x_exp*(h3 - he)/(h1 - hf);

mprintf("==================================================\n");
mprintf("  RESULTS  (NaN until property block is filled)\n");
mprintf("==================================================\n");
mprintf("  Expander outlet he    = %9.3f kJ/kg\n", he);
mprintf("  Liquid yield y        = %9.4f  (kg liquid / kg compressed)\n", y);
mprintf("\n");
if isnan(y) then
    mprintf("  SCAFFOLD: fill Section 2 with real-gas N2 enthalpies.\n");
    mprintf("  The expander term is what makes Claude out-yield Linde-Hampson\n");
    mprintf("  at a much lower pressure -- visible only with real-gas data.\n");
end
// END OF CLAUDE CYCLE SCAFFOLD
