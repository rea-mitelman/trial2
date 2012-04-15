function clean_signal=remove_stim_artifact3(raw_signal,raw_signal_Fs,stim_times,stim_times_Fs,artifact_duration)
%
% clean_signal=remove_stim_artifact
% (raw_signal,raw_signal_Fs,stim_time,stim_time_Fs,artifact_duration)
% Cleans the raw signal from the stimulus artifact, by averaging and
% subtraction of the average artifact. This may not be the ideal method,
% but it's suitable for spike sorting (where the problem is the threshold
% setting).
% Inputs:
% raw_signal: an analog vector of the raw signal (unit), with the stimulus artifacts
% raw_signal_Fs: sampling rate of the raw signal, in KHz (usually 25).
% stim_times: digital vector of the time samples of the stimuli, in seconds
% stim_time_Fs: sampling rate of the stimuli times, in KHz (usually 25)
% artifact_duration: the duration of the stimulus artifact, in milliseconds.
% Output:
% clean_signal: the clean signal, i.e. after removal of the artifacts,
% sampled in the same sampling frequency as the original signal.

%convert the time-stemps to indices
if isempty(stim_times)
	clean_signal=raw_signal;
	return
end
do_test=true;
stim_times=stim_times*1e3;%convert everything to msec & KHz
std_fraction=0.2;
stim_ixs=round(stim_times*raw_signal_Fs);
stim_ixs=stim_ixs(:);
n_stims=length(stim_ixs);
artifact_dur_ixs=round((artifact_duration)*raw_signal_Fs);
% artifact_ixs=0:(artifact_dur_ixs-1);
artifact_ixs=[1:artifact_dur_ixs]-1;
t=artifact_ixs/raw_signal_Fs;

all_artifact_ixs=repmat(stim_ixs,1,artifact_dur_ixs)+repmat(artifact_ixs,n_stims,1);
pre_artifact_ixs=repmat(stim_ixs-artifact_duration*raw_signal_Fs,1,artifact_dur_ixs)+repmat(artifact_ixs,n_stims,1);

if all_artifact_ixs(end) > length(raw_signal)
	error('last stimulus artifact outside boundaries, this needs to be solved')
end

all_artifacts=raw_signal(all_artifact_ixs);
all_pre_artifacts=raw_signal(pre_artifact_ixs);

%run over all indices, and create a matrix of all artifacts to extract
%mean, in vectorized matlab programing

mean_artifact=mean(all_artifacts);
clean_signal=raw_signal;
%run over all indices, this time to subtract the mean
% for i_art=1:n_stims
% 	clean_signal(all_artifact_ixs(i_art,:))=clean_signal(all_artifact_ixs(i_art,:))-mean_artifact;
% end
subtracted_artifacts=all_artifacts-repmat(mean_artifact,n_stims,1);

std_no_art=std(all_pre_artifacts(:));
std_vec=std(subtracted_artifacts);

local_max_std_i=find(std_vec(1:end-2) < std_vec(2:end-1) & std_vec(2:end-1) > std_vec(3:end)) + 1;
local_max_std_dev_i=local_max_std_i(std_vec(local_max_std_i)>5*std_no_art);
last_peak_i=max(local_max_std_dev_i);
fract_std=std_no_art+(std_vec(last_peak_i)-std_no_art)*std_fraction;
i_2cut=find(std_vec<fract_std);
i_2cut=i_2cut(i_2cut>last_peak_i);
i_2cut=i_2cut(1);
subtracted_artifacts(:,1:i_2cut)=0;

clean_signal(all_artifact_ixs)=subtracted_artifacts;





%% test
if do_test
	close all
	hold on
% 	plot(t,subtracted_artifacts,'c')
	plot(t,std_vec,'g','LineWidth',2)
	plot(t,ones(size(t))*1*std_no_art,'c','LineWidth',2)

	plot(t(local_max_std_i),std_vec(local_max_std_i),'+r')
	plot(t(local_max_std_dev_i),std_vec(local_max_std_dev_i),'*r')
	plot(t(last_peak_i),std_vec(last_peak_i),'or')
	

	plot(t(i_2cut),std_vec(i_2cut),'or')
	figure;
	plot(t,subtracted_artifacts)
	pause
end
% plot(t,(mean(abs(subtracted_artifacts))),'g','LineWidth',2)

% figure;hold on
% t=([1:size(all_artifacts,2)]-1)/raw_signal_Fs;
% plot(t,all_artifacts,'b')
% % plot(t,ones(size(t))*5*std(subtracted_artifacts(:)),'g','LineWidth',2)
% plot(t,ones(size(t))*5*mad(all_artifacts(:),1),'k','LineWidth',2)
% % plot(t,ones(size(t))*mean(subtracted_artifacts(:)),'k','LineWidth',2)
% plot(t,mad(all_artifacts,1),'r','LineWidth',2)
% plot(t,std(all_artifacts,1),'g','LineWidth',2)
%
% % errorbar(t,mean(subtracted_artifacts),std(subtracted_artifacts))
% % xlim([0,1])
	% plot(t,subtracted_artifacts,'b')
	% plot(t,ones(size(t))*5*std(subtracted_artifacts(:)),'g','LineWidth',2)
	% mad_no_art=mad(sig_no_art(:),1);
	% plot(t,ones(size(t))*mean(subtracted_artifacts(:)),'k','LineWidth',2)
	% plot(t,mad(subtracted_artifacts,1),'r','LineWidth',2)
	% plot(t,std(subtracted_artifacts,1),'g','LineWidth',2)
	
% 	plot(t,5*ones(size(t))*std_no_art,'k','LineWidth',2)
	
	%
