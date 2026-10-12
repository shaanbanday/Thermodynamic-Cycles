// ========================================================================
//  MILLER CYCLE MODEL  (Scilab port)
//  Over-expanded five-process idealization (one of several in use):
//    1->2 isentropic comp (r=V1/V2); 2->3 const-V heat in;
//    3->4 isentropic expansion to V4=e*V2 (e>r); 4->5 const-V to P1;
//    5->1 const-P exhaust. Efficiency computed from state points.
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
m=1.0; T1=300; P1=100e3; r=8.0; e=12.0; q_in=800e3; Q_in=m*q_in;
V1=m*R*T1/P1; V2=V1/r;
mprintf("==================================================\n");
mprintf("  CYCLE INPUT PARAMETERS\n");
mprintf("==================================================\n");
mprintf("  Mass m                = %8.3f kg\n", m);
mprintf("  State 1 temperature   = %8.3f K\n", T1);
mprintf("  State 1 pressure      = %8.3f kPa\n", P1/1000);
mprintf("  Compression ratio r   = %8.3f\n", r);
mprintf("  Expansion ratio e     = %8.3f\n", e);
mprintf("  Heat added q_in       = %8.3f kJ/kg\n", q_in/1000);
mprintf("\n");

// SECTION 3: STATE POINTS
T2=T1*r^(gamma-1); P2=P1*r^gamma;
V3=V2; T3=T2+Q_in/(m*cv); P3=m*R*T3/V3;
V4=e*V2; T4=T3*(V3/V4)^(gamma-1); P4=P3*(V3/V4)^gamma;
V5=V4; P5=P1; T5=P5*V5/(m*R);
P_states=[P1,P2,P3,P4,P5]; V_states=[V1,V2,V3,V4,V5]; T_states=[T1,T2,T3,T4,T5];
mprintf("==================================================\n");
mprintf("  STATE POINTS\n");
mprintf("==================================================\n");
mprintf("  State    P [kPa]     V [m^3]      T [K]\n");
mprintf("  --------------------------------------------\n");
for i=1:5
    mprintf("    %d    %9.2f   %9.6f   %8.2f\n", ..
            i, P_states(i)/1000, V_states(i), T_states(i));
end
mprintf("\n");

// SECTION 4: HEAT AND WORK
Q_12=0;            W_12=m*cv*(T1-T2);
W_23=0;            Q_23=m*cv*(T3-T2);
Q_34=0;            W_34=m*cv*(T3-T4);
W_45=0;            Q_45=m*cv*(T5-T4);
Q_51=m*cp*(T1-T5); W_51=m*R *(T1-T5);
Q_processes=[Q_12,Q_23,Q_34,Q_45,Q_51];
W_processes=[W_12,W_23,W_34,W_45,W_51];
labels=["1->2 isentropic comp";"2->3 const-V heat in";..
        "3->4 isentropic exp";"4->5 const-V heat out";..
        "5->1 const-P heat out"];
mprintf("==================================================\n");
mprintf("  HEAT AND WORK PER PROCESS\n");
mprintf("==================================================\n");
mprintf("  Process                    Q [kJ]      W [kJ]\n");
mprintf("  ------------------------------------------------\n");
for i=1:5
    mprintf("  %-22s  %9.3f   %9.3f\n", ..
            labels(i), Q_processes(i)/1000, W_processes(i)/1000);
end
mprintf("\n");

// SECTION 5: TOTALS AND EFFICIENCY
Q_out=abs(Q_45)+abs(Q_51);
W_net=sum(W_processes);
eta_cycle=W_net/Q_23;
energy_balance=(Q_23-Q_out)-W_net;
mprintf("==================================================\n");
mprintf("  CYCLE TOTALS AND EFFICIENCY\n");
mprintf("==================================================\n");
mprintf("  Heat added Q_in       = %9.3f kJ\n", Q_23/1000);
mprintf("  Heat rejected Q_out   = %9.3f kJ\n", Q_out/1000);
mprintf("  Net work W_net        = %9.3f kJ\n", W_net/1000);
mprintf("  Thermal efficiency    = %9.4f  (%.2f%%)\n", eta_cycle, eta_cycle*100);
mprintf("  Energy balance resid  = %9.3e kJ (should be ~0)\n", energy_balance/1000);
mprintf("\n");
if abs(energy_balance) < 1e-3 then
    mprintf("  CHECK PASSED: energy balance closes (Q_in - Q_out = W_net).\n");
else
    mprintf("  CHECK FAILED: energy balance does not close.\n");
end
mprintf("\n");

// SECTION 6: CURVES
N=100;
V_12=linspace(V1,V2,N); P_12=P1*(V1./V_12).^gamma;
P_23=linspace(P2,P3,N); V_23=V2*ones(1,N);
V_34=linspace(V3,V4,N); P_34=P3*(V3./V_34).^gamma;
P_45=linspace(P4,P5,N); V_45=V4*ones(1,N);
V_51=linspace(V5,V1,N); P_51=P1*ones(1,N);
V_curve=[V_12,V_23,V_34,V_45,V_51];
P_curve=[P_12,P_23,P_34,P_45,P_51];

// SECTION 7: ENTROPY
s1=0; s2=s1; s3=s2+cv*log(T3/T2); s4=s3; s5=s4+cv*log(T5/T4);
s_states=[s1,s2,s3,s4,s5];
T23=linspace(T2,T3,N); s23=s2+cv*log(T23/T2);
T45=linspace(T4,T5,N); s45=s4+cv*log(T45/T4);
T51=linspace(T5,T1,N); s51=s5+cp*log(T51/T5);
s_TS=[s1,s2,s23,s3,s4,s45,s5,s51,s1];
T_TS=[T1,T2,T23,T3,T4,T45,T5,T51,T1];

// SECTION 8: PLOTTING
scf(0);
plot(V_curve,P_curve/1000,"b-","LineWidth",2);
plot(V_states,P_states/1000,"ro","MarkerFaceColor","red","MarkerSize",8);
for i=1:5
    xstring(V_states(i),P_states(i)/1000,msprintf("  %d",i));
end
xlabel("Volume V [m^3]"); ylabel("Pressure P [kPa]");
title("Miller Cycle: P-V Diagram"); xgrid();

scf(1);
plot(s_TS,T_TS,"r-","LineWidth",2);
plot(s_states,T_states,"bo","MarkerFaceColor","blue","MarkerSize",8);
for i=1:5
    xstring(s_states(i),T_states(i),msprintf("  %d",i));
end
xlabel("Entropy change s [J/(kg*K)]"); ylabel("Temperature T [K]");
title("Miller Cycle: T-S Diagram"); xgrid();

mprintf("Plots generated. Miller cycle model complete.\n");
// END OF MILLER CYCLE MODEL
