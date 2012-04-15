function [scaled_signal, mult_fact]=denoise_multip(signal)
% Matrical solution to the problem:
% v_bar = mean(signal,2); is the average response vector.
% v_i = signal(:,i); is the ith response vector
% 
% A_i = v_i'*v_bar;
% B_i = norm(v_i);
% k_i = A(i)/B(i);
% k_i is the multiplication factor of the ith response (mult_fact(i) = k_i)
% 
% This is the consequence of taking d/dk_i of the expression:
% norm ( k_i*v_i - v_bar );
% which is the l2 norm of the subtraction of the ith response multiplied by
% the by the (requested) ith multiplication factor from the average vector
% response

do_plot=false;

mean_sig=mean(signal,2);

A=(signal'*mean_sig); 

B=sum(signal.^2,1)';

mult_fact = A./B;

mult_fact_mat=repmat(mult_fact',size(signal,1),1);

scaled_signal=mult_fact_mat .* signal;

fprintf('Multiplication factors are between %1.1f%% and %1.1f%%, with average delta-percentage of %1.1f%%.\n', 100*[min(mult_fact), max(mult_fact), abs(1-mean(mult_fact))])
if do_plot
	figure;
	subplot(2,1,1)
	plot(signal,'.')
	axis tight
	subplot(2,1,2);
	plot(scaled_signal,'.')
	axis tight
end
%%
% figure(2),clf,hold on
% plot(var(signal,[],2),'b'),plot(var(clean_signal,[],2),'g'); axis tight