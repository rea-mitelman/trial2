function clean_sig=remove_stim_artifact2(raw_sig,raw_sig_Fs,stim_times,stim_times_Fs,artifact_duration)
% clean_sig=remove_stim_artifact
% (raw_sig,raw_sig_Fs,stim_time,stim_time_Fs,artifact_duration)
% 
% Cleans the raw signal from the stimulus artifact, by averaging and
% subtraction of the average artifact. This may not be the ideal method,
% but it's suitable for spike sorting (where the problem is the threshold
% setting).
% Inputs:
% raw_sig: an analog vector of the raw signal (unit), with the stimulus artifacts 
% raw_sig_Fs: sampling rate of the raw signal, in KHz (usually 25).
% stim_times: digital vector of the time samples of the stimuli, in seconds
% stim_time_Fs: sampling rate of the stimuli times, in KHz (usually 25)
% artifact_duration: the duration of the stimulus artifact, in milliseconds.
% Output:
% clean_sig: the clean signal, i.e. after removal of the artifacts,
% sampled in the same sampling frequency as the original signal.

%%
global l alpha
clean_sig =[];
%convert everything to msec & KHz
stim_times=stim_times*1e3;

%upsample the original signal using interp
ud_samp_fact =  4 ; %the up- and down- sampling factor
upsamp_Fs = raw_sig_Fs*ud_samp_fact;
upsamp_sig = interp(raw_sig,ud_samp_fact,l,alpha);

% %% test
% t_raw=([1:length(raw_sig)]-1)/raw_sig_Fs;
% t_upsamp=([1:length(upsamp_sig)]-1)/upsamp_Fs;
% tmin=1.4003e4;tmax=1.4007e4;
% 
% tri=find(t_raw>tmin &t_raw<tmax);
% tui=find(t_upsamp>tmin &t_upsamp<tmax);
% plot(t_raw(tri),raw_sig(tri),t_upsamp(tui),upsamp_sig(tui))
% pause(0)
% %%

%convert the time-stemps to indices in the high sampled signal
stim_ixs=round(stim_times*upsamp_Fs);
stim_ixs=stim_ixs(:);
n_stims=length(stim_ixs);

% Artifact duration is incresed, to allow margins
artifact_dur_ixs=round(artifact_duration*upsamp_Fs);
% artifact_ixs=0:(artifact_dur_ixs-1);
artifact_ixs=(-2*ud_samp_fact):(artifact_dur_ixs-1+2*ud_samp_fact);
artifact_dur_ixs=length(artifact_ixs);

%run over all stimuli and create a matrix of all artifacts to extract
%mean, in vectorized matlab programing

all_artifact_ixs=repmat(stim_ixs,1,artifact_dur_ixs)+repmat(artifact_ixs,n_stims,1);
if all_artifact_ixs(end) > length(upsamp_sig)
	error('last stimulus artifact outside boundaries, this needs to be solved')
end
all_artifacts=upsamp_sig(all_artifact_ixs);
% % %%  test
% plot(all_artifacts')
% pause(0)

% artifacts are time locked to the (first) minimum and margins are cut !!!

[all_artifacts_lock,all_shifts]=lock_artifacts(all_artifacts);
subplot(2,1,1)
plot(all_artifacts_lock')
xlim([0,150])

subplot(2,1,2)
plot([all_artifacts_lock-repmat(mean(all_artifacts_lock),size(all_artifacts_lock,1),1)]')
xlim([0,150])

return

mean_artifact=mean(all_artifacts);
%% 
clean_sig=raw_sig;
%run over all indices, this time to substract the mean, pay attention to
%correct time lock !!!

for i_art=1:n_stims
	clean_sig(all_artifact_ixs(i_art,:))=clean_sig(all_artifact_ixs(i_art,:))-mean_artifact;
end

% signal is downsampled to the original sampling fequency !!!