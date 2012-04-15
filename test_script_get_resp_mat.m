% test_script_get_resp_mat;
close all
Fs=25;
r=10;
t=[1:10*Fs*1000]/Fs/1000; %time in seconds
x=randn(size(t));
stim_times_sec=[1:1:9];
rd=[-0 1];

for s=stim_times_sec
	x(t==s)=50;
end

[x_us t_us] = my_upsamp(x,t,r);

figure(1);clf;
subplot(2,1,1);hold on;
plot(x); plot([stim_times_sec;stim_times_sec],[0;0],'or','MarkerSize',5)
subplot(2,1,2);hold on;

% stim_times=stim_times_sec*1000;
% stim_ixs=stim_times*Fs;
% stim_binar=zeros(size(x));stim_binar(stim_ixs)=1;
% stim_binar_upsamp=my_upsamp(stim_binar,r);
% stim_upsamp_ixs=find(stim_binar_upsamp>0.99);
% stim_upsamp=stim_upsamp_ixs/r/Fs;
% stim_upsamp_sec=stim_upsamp/1000;
stim_upsamp_sec=stim_times_sec + (1-r)/(Fs*r*1e3);

plot(x_us);plot([stim_times_sec;stim_times_sec],[0;0],'or','MarkerSize',5)
[m,tt]=get_resp_mat_trial(x,stim_times_sec,Fs,rd);
figure(2)
subplot(2,1,1);plot(m); axis tight

[m,tt]=get_resp_mat_trial(x_us,stim_upsamp_sec,Fs*r,rd);
subplot(2,1,2);plot(m); axis tight