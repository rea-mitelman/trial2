function [jit_ixs, corr_mat]=get_temp_jit(us_signal, stim_times_us, Fs_us, resp_dur, max_jit_per_itt)

% The function corrects for temporal jitters in response vectors, in an
% itterative manner, by minimizing an (integer) jitter, different per
% response. 
% org_mat is a matrix of the responses, sized (n_responses X n_samples)
% i.e. each row is a response.
% max_jit_per_itt is the maximal temporal jitter examined (in samples), per
% itteration, in both directions (i.e. positive and negative).
% jit_ixs is a column vector sized n_responses, which defines the correction
% required per response.
% corr_mat is the corrected matrix, sized 
% (n_responses X n_samples-2*max_jit_per_itt
% 
% 
% 
% %test
% % org_mat = rand(200,5);
% close all
% max_jit_per_itt=2;
% max_itter=100;
% N=200;
% 
% t=0:100;
% jit=round((rand(N,1)-.5)*2*5);
% jit=repmat(jit,1,101);
% tt=repmat(t,N,1);
% tt=tt+jit;
% org_mat=sin(pi*tt/10).*exp(-tt/10);%+randn(size(tt))*0.1;
% 
% % org_mat=repmat(sin(pi*t/10).*exp(-t/25),20,1);
% % org_mat=org_mat+randn(size(org_mat))*.5;
% %%

org_mat=get_resp_mat(us_signal, stim_times_us, Fs_us, resp_dur)';

do_corr=true;
n_itter=0;
jit_vec=-max_jit_per_itt:max_jit_per_itt;
[n_resp n_samp]=size(org_mat);
shift_vec=max_jit_per_itt+[1:n_samp];
max_itter=100;
do_plot=false;
jit_ixs=zeros(n_resp,1);

for ii=1:2*max_jit_per_itt+1
    jit=jit_vec(ii);
    ixs(ii,:)=jit+shift_vec ;
end

corr_mat=org_mat;
while do_corr && n_itter<max_itter
    
    if do_plot
        clf, hold on
        subplot(2,1,1),plot(corr_mat'), plot(nanmean(corr_mat),'k','LineWidth',5)
        subplot(2,1,2), plot(std(corr_mat))
        pause(0.1)
    end
    
	n_itter=n_itter+1;
	pad_mat=[NaN(n_resp,max_jit_per_itt) , corr_mat , NaN(n_resp,max_jit_per_itt)];
	mean_resp_mat=repmat(nanmean(corr_mat),n_resp,1);
    
    for ii=1:2*max_jit_per_itt+1 %trying all possible jitters
		jittered_mat=pad_mat(:,ixs(ii,:));
		diff_vec(:,ii)=nanmean((jittered_mat-mean_resp_mat).^2,2) ;
    end	
    
	[~,min_ixs]=min(diff_vec,[],2);
    jit_ixs=jit_ixs+min_ixs-max_jit_per_itt-1;
    
    corr_mat=nan(size(corr_mat));
    for jj=1:n_resp %taking the best jitter per response
        corr_mat(jj,:)=pad_mat(jj,ixs(min_ixs(jj),:));
    end
    if do_plot
        std_vec(n_itter)=nanmean(nanstd(corr_mat));
    end
    
    if all(min_ixs==max_jit_per_itt+1)
        do_corr=false;
    end
end
fprintf('Temporal jitter is between %1.0f and %1.0f samples. Converged after %1.0f itterations.\n',...
    min(jit_ixs), max(jit_ixs), n_itter);

if do_plot
    figure
    plot(std_vec);
    keyboard
end