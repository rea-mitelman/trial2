function t_upsamp=get_upsamp_times(t_org,Fs,r)
% When upsampling a signal, times of events that were given in the original
% sampling rate might be distorted. This distortion is (r-1)/r samples,
% when r is the ration in which the signal was upsampled. This function
% works for the conventions in our data (which are counter-intuitive, to
% say the least):
% t_upsamp - a vector of the times of the events, after the upsampling, 
% IN SECONDS!
% t_org - a vector of the times of the events in the original sampling rate
% IN SECONDS!
% Fs - the original sampling rate, IN KHz!!


t_upsamp = t_org - (r-1)/r * 1/Fs * 1e-3;