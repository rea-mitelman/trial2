function clean_signal = remove_artifact_advanced...
    (signal, signal_Fs, stim_times, stim_times_Fs, us_factor, max_itt_jit, ...
    art_begin, art_end, max_dead_time_dur, do_lin_decay)

% parameters:

% art_begin=0;
% art_end=5;
% do_lin_decay=false;
%%
resp_dur=[art_begin art_end];

%Getting rid of saturated indices:
% [unsat_signal, unsat_signal_ixs]=remove_saturation(signal);

sat_times = get_sat_ixs(signal, stim_times, signal_Fs, resp_dur);

% upsampling the signal
us_signal = my_upsamp(signal,us_factor);
clear signal
Fs_us=signal_Fs*us_factor; %Fs_us is the sampling rate of the upsampled signal

if stim_times_Fs~=signal_Fs
    warning('Sampling rate of the signal and stimuli times are different. The code was not debugged for these cases')
end



stim_times_us=get_upsamp_times(stim_times,stim_times_Fs,us_factor); %stim_times, though digital, require correction when going to higher sampling rate

% [resp_mat_us,t_us]=get_resp_mat(us_signal, stim_times_us, Fs_us, resp_dur);

[jit_ixs, corr_mat]=get_temp_jit(us_signal, stim_times_us, Fs_us, resp_dur, max_itt_jit); %correcting for temporal jitter of the stimuli

% Using the jittering indices correction to correct the stimuli time
stim_times_corrected=stim_times_us+jit_ixs/Fs_us/1000;
[resp_mat_us_dejit,t2]=get_resp_mat(us_signal, stim_times_corrected, Fs_us, resp_dur);
sat_times=sat_times+[min(jit_ixs) max(jit_ixs)+1]*2/Fs_us; %correct for the jitter, plus margins
sat_times(1) = max(sat_times(1),0); %prevent zeroing before stimulus;
sat_times(2) = min(sat_times(2),max_dead_time_dur); %zeroing no more than one millisecond
fprintf('Saturation time is between %1.2f and %1.2f msec. from stimulus onset\n',sat_times);
% This probed to be both of little effect in the agarose data, and
% potentially noise inducing in the physiological data...
% [resp_mat_us_dejit_denoise, mult_factor]=
% denoise_multip(resp_mat_us_dejit(t2<sat_times(1) | t2>sat_times(2),:)); %
clean_us_signal=remove_stim_artifact(...
	us_signal, Fs_us, stim_times_corrected, resp_dur(2), sat_times, false, do_lin_decay);
clear us_signal

clean_signal=my_decimate(clean_us_signal,us_factor);