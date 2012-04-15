function upsamp_sig=my_upsamp_ign_sat(signal,r)
% trying various methods of upsampling:
% 
maxV=5;a2d_res=14;
minmax_val=maxV-2*maxV*2^-a2d_res;

sat_ixs = abs(signal)>=minmax_val;

sat_ixs_exc_edges = sat_ixs & [0 ~diff(sat_ixs,2) 0];

unsat_signal_ixs=~sat_ixs_exc_edges;
% unsat_signal_ixs=~sat_ixs;



allT=1:length(signal);
unsatT=allT(unsat_signal_ixs);
signal_sat_dropped=signal(unsat_signal_ixs);
allT_upsamp=linspace(allT(1),(allT(end)+(r-1)/r),length(allT)*r);
upsamp_sig=interp1(unsatT, signal_sat_dropped, allT_upsamp,'spline');



% upsamp_sig1=interp1(t,x,upsamp_t,'spline');
% upsamp_sig2=interp1(t,x,upsamp_t,'pchip');
% upsamp_sig3=interp(x,r);



