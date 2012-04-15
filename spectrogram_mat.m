function [S, F, T, P] = spectrogram_mat(varargin)
X=varargin{1};

for ii=1:size(X,2)
	[This_S, F, T, This_P]=spectrogram(X(:,ii),varargin{2:end});
	if ii==1
		S=This_S;
		P=This_P;
	else
		S=1/ii*(This_S+(ii-1)*S);
		P=1/ii*(This_P+(ii-1)*P);
	end
end


