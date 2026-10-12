// ========================================================================
//  LINDE-HAMPSON LIQUEFACTION CYCLE  (SCAFFOLD -- REAL-GAS DATA REQUIRED)
//  Repository: thermodynamic-cycles
//  Working fluid: nitrogen (or air) -- REAL gas, not ideal
//
//  WHY NO IDEAL-GAS VERSION: this cycle liquefies gas using the
//  Joule-Thomson effect, the temperature drop of a real gas on throttling
//  below its inversion temperature. For an ideal gas the JT coefficient is
//  exactly zero, so an ideal-gas model would predict NO cooling and NO
//  liquefaction. The physics only exists in real-gas property data.
//
//  Process:
//    1 : makeup gas at ambient T, low P
//    2 : after compressor (isothermal, high P) -- aftercooled to T1
//    3 : after counterflow heat exchanger (cooled by returning cold gas)
//    4 : after JT valve (two-phase, low P) -- liquid fraction y forms
//    g : saturated vapour returning through the exchanger
//    f : saturated liquid drawn off as product
//
//  Liquid yield from a first-law balance over HX + valve (the standard
//  Linde result):   y = (h1 - h2) / (h1 - hf)
//  where all h are REAL-gas enthalpies [kJ/kg].
//
//  PROPERTY DEPENDENCY: real-gas enthalpy h(T,P) for N2. Fill from CoolProp
//  (PropsSI("H","T",T,"P",P,"Nitrogen")) or NIST. NaN until then.
// ========================================================================

clear; clc; xdel(winsid());

// ------------------------------------------------------------------------
//  SECTION 1: CYCLE CONDITIONS
// ------------------------------------------------------------------------
fluid  = "Nitrogen";
T_amb  = 300;        // compressor/aftercooler temperature  [K]
P_low  = 100e3;      // suction / product pressure          [Pa]
P_high = 20e6;       // compressor discharge pressure       [Pa]

mprintf("==================================================\n");
mprintf("  LINDE-HAMPSON LIQUEFACTION (%s)\n", fluid);
mprintf("==================================================\n");
mprintf("  Ambient temperature   = %8.1f K\n", T_amb);
mprintf("  Low pressure          = %8.1f kPa\n", P_low/1000);
mprintf("  High pressure         = %8.1f kPa\n", P_high/1000);
mprintf("\n");

// ------------------------------------------------------------------------
//  SECTION 2: REAL-GAS ENTHALPIES  <<< FILL THESE (CoolProp/NIST) >>>
//  h1 : gas at (T_amb, P_low)
//  h2 : gas at (T_amb, P_high)   -- same T, higher P: real gas differs
//  hf : saturated LIQUID at P_low (product)
//  hg : saturated VAPOUR  at P_low (return stream)
// ------------------------------------------------------------------------
h1 = %nan;     // e.g. PropsSI("H","T",300,"P",1e5,"Nitrogen")/1000  [kJ/kg]
h2 = %nan;     //      PropsSI("H","T",300,"P",20e6,"Nitrogen")/1000
hf = %nan;     //      PropsSI("H","Q",0,"P",1e5,"Nitrogen")/1000
hg = %nan;     //      PropsSI("H","Q",1,"P",1e5,"Nitrogen")/1000

// ------------------------------------------------------------------------
//  SECTION 3: LIQUID YIELD AND WORK  (logic correct; needs h-values)
// ------------------------------------------------------------------------
y = (h1 - h2) / (h1 - hf);          // fraction liquefied per unit compressed

// Ideal isothermal compressor work (reversible), real-gas form:
//   w_comp = T_amb*(s1 - s2) - (h1 - h2)   [needs entropies too]
// Simit to the enthalpy-only yield here; add s1,s2 if you want work.
// Work per unit mass LIQUEFIED = w_comp / y.

mprintf("==================================================\n");
mprintf("  RESULTS  (NaN until property block is filled)\n");
mprintf("==================================================\n");
mprintf("  Liquid yield y        = %9.4f  (kg liquid / kg compressed)\n", y);
mprintf("\n");
if isnan(y) then
    mprintf("  SCAFFOLD: fill Section 2 with real-gas N2 enthalpies.\n");
    mprintf("  Reminder: an ideal-gas model gives y <= 0 here by construction,\n");
    mprintf("  because the Joule-Thomson effect vanishes for an ideal gas.\n");
else
    if y <= 0 then
        mprintf("  NOTE: y <= 0 means no liquefaction at these conditions\n");
        mprintf("  (above inversion T, or pressure span too small).\n");
    end
end
// END OF LINDE-HAMPSON SCAFFOLD
