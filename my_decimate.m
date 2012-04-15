function odata=my_decimate(varargin)
% This function takes the matlab deciamte function, and makes it the exact
% oposite of the my_upsamp function (which upsamples using the matlab
% "interp" function. 
% The original deciamte function "works forward" if r is a factor of the
% input data's length, i.e. it starts with the r'th sample untill the last
% one. By adding a dummy sample at the end, decimate returns the first
% sample of the original signal and the dummy one. The function then frops
% the dummy sample, returning the desired vector.
% 
varargin{1}(end+1)=varargin{1}(end-1);

odata=decimate(varargin{:});

odata=odata(1:end-1);




