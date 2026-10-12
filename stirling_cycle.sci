// ========================================================================
//  STIRLING CYCLE MODEL  (Scilab port)
//  Two isothermals + two isochorics with ideal regeneration.
//    1->2 iso-T expansion at T_hot; 2->3 isochoric cool (to regenerator);
//    3->4 iso-T compression at T_cold; 4->1 isochoric heat (from regen).
//  With perfect regeneration eta = 1 - T_cold/T_hot = Carnot.
// ========================================================================

clear; clc; xdel(winsid());

// SECTION 1: PROPERTIES
R=287; gamma=1.4; cv=R/(gamma-1); cp=gamma*cv;
mprintf("==================================================\n");
mprintf("  WORKING FLUID PROPERTIES (air, ideal gas)\n");
mprintf("==================================================\n");
mprintf("  Gas constant R        = %8.3f J/(kg*K)\n", R);
mprintf("  Specific heat ratio   = %8.3f\n", gamma);
mprintf("  cv                    = %8.3f J/(kg*K)\n", cv);
mprintf("  cp                    = %8.3f J/(kg*K)\n", cp);
mprintf("\n");

// SECTION 2: INPUTS
m=1.0; T_hot=800; T_cold=300; P1=600e3; rv=2.0;
V1=m*R*T_hot/P1; V2=rv*V1;
mprintf("==================================================\n");
mprintf("  CYCLE INPUT PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Mass m                = %8.3f kg\n", m);
mprintf("  Hot temperature       = %8.3f K\n", T_hot);
mprintf("  Cold temperature      = %8.3f K\n", T_cold);
mprintf("  State 1 pressure      = %8.3f kPa\n", P1/1000);
mprintf("  Volume ratio V2/V1    = %8.3f\n", rv);
mprintf("\n");

// SECTION 3: STATE POINTS
T1=T_hot;  P1_=P1;          // V1 already set
T2=T_hot;  P2=m*R*T2/V2;
T3=T_cold; V3=V2; P3=m*R*T3/V3;
T4=T_cold; V4=V1; P4=m*R*T4/V4;
P_states=[P1,P2,P3,P4]; V_states=[V1,V2,V3,V4]; T_states=[T1,T2,T3,T4];
mprintf("==================================================\n");
mprintf("  STATE POINTS\n");
mprintf("==================================================\n");
mprintf("  State    P [kPa]     V [m^3]      T [K]\n");
mprintf("  --------------------------------------------\n");
for i=1:4
    mprintf("    %d    %9.2f   %9.6f   %8.2f\n", ..
            i, P_states(i)/1000, V_states(i), T_states(i));
end
mprintf("\n");

// SECTION 4: HEAT AND WORK
W_12=m*R*T_hot*log(V2/V1);  Q_12=W_12;
W_23=0;                     Q_23=m*cv*(T3-T2);
W_34=m*R*T_cold*log(V4/V3); Q_34=W_34;
W_41=0;                     Q_41=m*cv*(T1-T4);
Q_processes=[Q_12,Q_23,Q_34,Q_41]; W_processes=[W_12,W_23,W_34,W_41];
labels=["1->2 iso-T expansion";"2->3 isochoric cool (regen)";..
        "3->4 iso-T compression";"4->1 isochoric heat (regen)"];
mprintf("==================================================\n");
mprintf("  HEAT AND WORK PER PROCESS\n");
mprintf("==================================================\n");
mprintf("  Process                       Q [kJ]      W [kJ]\n");
mprintf("  ---------------------------------------------------\n");
for i=1:4
    mprintf("  %-25s  %9.3f   %9.3f\n", ..
            labels(i), Q_processes(i)/1000, W_processes(i)/1000);
end
mprintf("\n");

// SECTION 5: TOTALS AND EFFICIENCY
Q_regen=m*cv*(T_hot-T_cold);
Q_in_ext=Q_12; Q_out_ext=abs(Q_34);
W_net=sum(W_processes);
eta_cycle=W_net/Q_in_ext;
eta_carnot=1-T_cold/T_hot;
mprintf("==================================================\n");
mprintf("  CYCLE TOTALS AND EFFICIENCY (ideal regeneration)\n");
mprintf("==================================================\n");
mprintf("  Regenerator duty      = %9.3f kJ (each isochoric leg)\n", Q_regen/1000);
mprintf("  External heat in      = %9.3f kJ\n", Q_in_ext/1000);
mprintf("  External heat out     = %9.3f kJ\n", Q_out_ext/1000);
mprintf("  Net work W_net        = %9.3f kJ\n", W_net/1000);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_cycle, eta_cycle*100);
mprintf("  Carnot efficiency     = %9.4f  (%.2f%%)\n", eta_carnot, eta_carnot*100);
mprintf("\n");
if abs(eta_cycle-eta_carnot)<1e-6 then
    mprintf("  CHECK PASSED: regenerated Stirling reaches Carnot efficiency.\n");
else
    mprintf("  CHECK FAILED: efficiency does not match Carnot limit.\n");
end
mprintf("\n");

// SECTION 6: CURVES
N=100;
V_12=linspace(V1,V2,N); P_12=m*R*T_hot./V_12;
P_23=linspace(P2,P3,N); V_23=V2*ones(1,N);
V_34=linspace(V3,V4,N); P_34=m*R*T_cold./V_34;
P_41=linspace(P4,P1,N); V_41=V1*ones(1,N);
V_curve=[V_12,V_23,V_34,V_41]; P_curve=[P_12,P_23,P_34,P_41];

// SECTION 7: ENTROPY
s1=0; s2=s1+R*log(V2/V1); s3=s2+cv*log(T3/T2); s4=s3+R*log(V4/V3);
s_states=[s1,s2,s3,s4];
T23=linspace(T2,T3,N); s23=s2+cv*log(T23/T2);
T41=linspace(T4,T1,N); s41=s4+cv*log(T41/T4);
s_TS=[s1,s2,s23,s3,s4,s41,s1];
T_TS=[T1,T2,T23,T3,T4,T41,T1];

// SECTION 8: PLOTTING
scf(0);
plot(V_curve,P_curve/1000,"b-","LineWidth",2);
plot(V_states,P_states/1000,"ro","MarkerFaceColor","red","MarkerSize",8);
for i=1:4
    xstring(V_states(i),P_states(i)/1000,msprintf("  %d",i));
end
xlabel("Volume V [m^3]"); ylabel("Pressure P [kPa]");
title("Stirling Cycle: P-V Diagram"); xgrid();

scf(1);
plot(s_TS,T_TS,"r-","LineWidth",2);
plot(s_states,T_states,"bo","MarkerFaceColor","blue","MarkerSize",8);
for i=1:4
    xstring(s_states(i),T_states(i),msprintf("  %d",i));
end
xlabel("Entropy change s [J/(kg*K)]"); ylabel("Temperature T [K]");
title("Stirling Cycle: T-S Diagram"); xgrid();

mprintf("Plots generated. Stirling cycle model complete.\n");
// END OF STIRLING CYCLE MODEL
