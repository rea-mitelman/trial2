function [resp_mat,t]=get_resp_mat(signal, stim_times_sec, Fs, resp_dur)
% The function returns a matrix of response to all stimuli in a given
% signal. If the output exceeds the bounderies of the signal, the vector is
% padded with NaNs.
% signal -  a vector of the signal which should be cut around the stimuli
% times (unit/LFP/...)
% stim_times - a vector of the stimuli times, IN SECONDS!
% Fs - the sampling rate of the signal IN KHz!
% resp_dur - two entry vector, indicating the pre- and post- stimulus
% time to be included in each vector of the output matrix, IN MILLISECONDS!
% resp_mat - the output matrix, sized:
% (# samples in response vector)X(# stimuli)
% t - output times in milliseconds, spanning the two entries in the input
% "resp_dur"

%Switching all to msec/KHz
stim_times=stim_times_sec*1e3;

% Now switching all sizes to samples and keep a notation of column vectors
signal=signal(:);
stim_ixs=round(stim_times(:)*Fs);
resp_dur_ixs=round(resp_dur*Fs);

% Pad the signal with NaN from both sides, correct stims accordingly.
pad_signal=[
	NaN(-resp_dur_ixs(1),1);
	signal;
	NaN(resp_dur(2),1)
	];
pad_stim_ixs=stim_ixs-resp_dur_ixs(1);

n_stims=length(stim_ixs);


% Prepare an indices matrix:
resp_ixs_vec=resp_dur_ixs(1):resp_dur_ixs(2);
n_samps=length(resp_ixs_vec);
all_resp_ixs=repmat(pad_stim_ixs,1,n_samps)+repmat(resp_ixs_vec,n_stims,1);

%Finally, taking the vectors of the signal, according to the indices matrix
resp_mat=pad_signal(all_resp_ixs)';

t=resp_dur(1):1/Fs:resp_dur(2);
