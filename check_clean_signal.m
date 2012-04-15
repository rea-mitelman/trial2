% check_clean_signal
clear
global l alpha
l = 1; alpha = 1e-5;
for f=1:29
	fn=sprintf('%02.0f',f);
% 		file_base_name = ['D:\Rea''s_Documents\Prut\Ctx-Thal\data\h040210\MAT\h0402100' fn ];
	file_base_name = ['D:\Rea''s_Documents\Prut\Ctx-Thal\data\h050210\MAT\h0502100' fn ];
	
	for elect_num=1:4;
		[clean_signal,t,Unit1]=remove_stim_artifact_from_file(file_base_name,elect_num);
	end

	% % clean_signal=remove_stim_artifact(Unit1,Unit1_KHz,AMstim_on,AMstim_on_KHz,3);
	% % t=[0:length(clean_signal)-1]/Unit1_KHz;
% 	plot(t,Unit1,'k',t,clean_signal,'r')
% 	pause
end
