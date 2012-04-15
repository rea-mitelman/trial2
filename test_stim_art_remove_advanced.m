% This script checks for advnaced methods for stimulus artifact removal
% The tested data is the in-agrarose data

% First, load the data:
clear; close all;

upsamp_factor=8;
resp_dur=[0 10];
max_itt_jit=1;
max_dead_time_dur=0.75;
do_lin_decay=false;

art_begin=resp_dur(1); art_end=resp_dur(2);

root_dir = get_data_root_dir;
% date_str='y310112'; %files 31:33 here are stimulation in agarose
date_str='y150212'; %"best typical" day
load_dir=sprintf('%s%s\\MAT\\',root_dir,date_str);
files=15:44;
% files=32:33;%9:30;

% upsamp_factor_vec=[8];

for ff=files
	load(sprintf('%s\\%s%03.0f_wvf.mat',load_dir,date_str,ff));
	load(sprintf('%s\\%s%03.0f_bhv.mat',load_dir,date_str,ff));
	[stim_times, stim_times_Fs] = get_stim_times;
	if isempty(stim_times)
		fprintf('skipping file %2.0f\n',ff)
		continue
	end
	for elec=1:4
        % 		for u = 1:length(upsamp_factor_vec);
% 			upsamp_factor=upsamp_factor_vec(u);
			signal=eval(['Unit' num2str(elec)]);
			Fs=eval(['Unit' num2str(elec) '_KHz']);
            signal_clean=remove_artifact_advanced( ...
                signal, Fs, stim_times, stim_times_Fs, upsamp_factor, max_itt_jit, art_begin, art_end, max_dead_time_dur, do_lin_decay);
            close all
%             t=[0:length(signal_clean)-1]/Fs;
%             plot(stim_times*1e3*[1 1],[-5 5],'-r',t,signal_clean,'-');
            [m_org,t]=get_resp_mat(signal, stim_times, Fs, [-5 30]);
            m_clean = get_resp_mat(signal_clean, stim_times, Fs, [-5 30]);
            figure
            subplot(2,1,1)
            hold on; plot(t,m_org);plot(t,mean(m_org,2),'k','LineWidth',3)
            axis tight
            yl=ylim;
            subplot(2,1,2)
            hold on; plot(t,m_clean);plot(t,mean(m_clean,2),'k','LineWidth',3)
            ylim(yl)
            
            pause(1)
            close all
% 			plot(t,signal,'c',t,signal_clean,'m');
% 			title(sprintf('File %1.0f, Elect. %1.0f, up/down sampling ratio %1.0f',ff,elec,upsamp_factor))
% 			axis tight
% 			keyboard
%             [upsamp_signal]=my_upsamp(signal,upsamp_factor);
%             stim_times_upsamp=get_upsamp_times(stim_times,Fs,upsamp_factor);
% 			[resp_mat_upsamp,t_upsamp]=get_resp_mat...
%                 (upsamp_signal, stim_times_upsamp, Fs*upsamp_factor, resp_dur);
% 			[jit_ixs, corr_mat]=get_temp_jit(resp_mat_upsamp',3);
% 			[resp_mat_upsamp_dejit,t2]=get_resp_mat(upsamp_signal, stim_times_upsamp+jit_ixs/Fs/1000/upsamp_factor, Fs*upsamp_factor, resp_dur);

% 			[resp_mat,t]=get_resp_mat(upsamp_signal, stim_times, Fs, resp_dur);
% 			[s,f,T,p]=spectrogram_mat(resp_mat_upsamp_dejit,5,[],[],Fs*upsamp_factor);
% 			figure(1);clf;
% 			subplot(3,1,1)
%             T=T+resp_dur(1);
% 			pcolor(T,f,10*log10(p)); axis tight; shading flat
%             % 			subplot(3,1,1)
%             %             plot(t,mean(resp_mat,2))
%             title(sprintf('File %1.0f, electrode %1.0f',ff, elec))
%             
%             subplot(3,1,2);hold on
%             pre=10*log10(sum(p(:,T<0 & T>=-5),2));
%             artf=10*log10(sum(p(:,T>0 & T<=2),2));
%             resp=10*log10(sum(p(:,T>0 & T<=5),2));
%             h(1)=plot(f,pre,'b');
%             h(2)=plot(f,artf,'g');
%             h(3)=plot(f,resp,'r');
%             axis tight
%             lg={'Pre-stim','Artifact','Response'};
%             legend(h,lg)
% 
%             subplot(3,1,3);
%             plot(f,(resp-pre)./(artf-pre));axis tight;
% % 			
            
%             pause
% 			keyboard
			
% 			
% 			
% 			[upsamp_signal]=my_upsamp(signal,upsamp_factor);
% 		
% 			stim_times_upsamp=get_upsamp_times(stim_times,Fs,upsamp_factor);
% 			[resp_mat_upsamp,t_upsamp]=get_resp_mat(upsamp_signal, stim_times_upsamp, Fs*upsamp_factor, resp_dur);
% 		
% 			[jit_ixs, corr_mat]=get_temp_jit(resp_mat_upsamp',3);
% 			[resp_mat2,t2]=get_resp_mat(upsamp_signal, stim_times_upsamp+jit_ixs/Fs/1000/upsamp_factor, Fs*upsamp_factor, resp_dur);
% 			%         keyboard
% 			subplot(length(upsamp_factor_vec),2,2*u-1)
% 			plot(t2,resp_mat2)
% 			title(sprintf('Upsampling ration: %1.0f',upsamp_factor));
% 			subplot(length(upsamp_factor_vec),2,2*u)
% 			plot(t2,var(resp_mat2,[],2))
% 		end
% 		pause
	end
	
end

% Satages according to Wichmann (2000):
% X 1. Bandpass for max. signal energy and min. artifact energy (found to be useless)
% V 2. Average the respomse 
% V 3. Time gitter optimization, find updated stim. times (consider
%      upsampling, R.M.)
% V 4. Average response after gitter correction
% V- 5. Scaling optimizatin, find scaling factor per response
% V 6. remove the scale version of the artifact from the updated timin
%% LIMIT THE NUMBER OF INDEX JITTERING, TO PREVENT DIVERGENCE!