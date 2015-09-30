function [lnan] = nanstretch( x )
%NANSTRETCH - This function searches a given data vector for NaNs and
%determines the lengths of continuous NaN stretches within the vector.  It
%is intended to allow quick determination of whether NaNs may be safely
%interpolated over if they represent a suitably small chunck of your data.
% C. Ryan Manzer, Moss Landing Marine Labs - 7/9/2015
% INPUTS
%   x - data vector containing NaN values
% OUTPUTS
%   lnan - a cell matrix of the lengths of the NaN stretches and their indeces
%   within the x data vector.
j = 1; %initializing our counter
lnan={}; % initializing our cell matrix for lnan

start=0;stop=0;
for i = 1:length(x)
    if isnan(x(i))==1 && start == 0
        start=i;
    elseif isnan(x(i))==0 && start > 0 
        stop=i-1;
        lnan{j,1}=length(x(start:stop));
        lnan{j,2}=start:stop;
        j=j+1;
        start=0;stop=0;
    end
end
end

