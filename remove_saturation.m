function [unsat_signal, unsat_signal_ixs]=remove_saturation(signal)
%%
maxV=5;a2d_res=14;
minmax_val=maxV-2*maxV*2^-a2d_res;

sat_ixs = abs(signal)>=minmax_val;

sat_ixs_exc_edges = sat_ixs & [0 ~diff(sat_ixs,2) 0];

% unsat_signal_ixs=~sat_ixs_exc_edges;
unsat_signal_ixs=~sat_ixs;



allT=1:length(signal);
unsatT=allT(unsat_signal_ixs);
signal_sat_dropped=signal(unsat_signal_ixs);

unsat_signal=interp1(unsatT, signal_sat_dropped, allT,'pchip'); %% change interpulation method!


% close all
% figure
% % plot(unsatT, signal_sat_dropped);
% plot(allT,unsat_signal,allT, signal)
% %%
% figure
% clf;
% hold on
% plot(allT,unsat_signal_ixs,'.-')
% plot(allT(1:end-1)+.5,diff(unsat_signal_ixs),'.-g')
% plot(allT(2:end-1),diff(unsat_signal_ixs,2),'.-r')
% %%
% figure
% clf;
% hold on
% plot(allT,sat_ixs,'.-')
% plot(allT(1:end-1)+.5,diff(sat_ixs),'.-g')
% plot(allT(2:end-1),diff(sat_ixs,2),'.-r')
