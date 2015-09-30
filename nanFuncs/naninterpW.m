function [ x, tind ] = naninterpW(x,w,method)
% NaNInterpW - a function for interpolating over NaNs in a data vector
% within a specific window.  If NaN values are found on either end of the
% data vector, and their length is greater than the window value provided,
% then x will be truncated to remove these values.  Otherwise this function
% will utilize the extrapolate option in interp1 to extrapolate those
% values.
% INPUTS
%   x - the data vector containing NaNs to be interpolated over
%   w - the length of the window over which it is valid to interpolate.
%   NaN strentches that are longer than this will be retained in the
%   resultant vector.
%   method - one of the interpolation methods used in interp1.  See 'help
%   interp1' for more information.
% OUTPUTS
%   x - data vector with all applicable NaN values interpolated over
%   tind - the index values of any data points that had to be truncated
%   off either end of our vector
%
% 6/25/2015 C. Ryan Manzer, Moss Landing Marine Labs
%X=zeros(size(x));
% finding where x is valid and where it contains NaNs
nanx=find(isnan(x)==1);
tind={}; tfront=false;tend=false;
% If there is nothing to interpolate over we can skip all this
if isempty(nanx) ==1
    return
end
extrap = false; % we start by assuming we cannot extrapolate 
% Checking to see if our vector begins or ends with NaN
if nanx(1) == 1 || max(nanx) == length(x) 
    if nanx(1) ~= 1 || find(diff(nanx)>1,1,'first') <= (w)  % if the length of the NaNs on the front is less than our window
        extrap = true; % we can extrapolate over them
        tfront = false; % and we don't need to truncate the front end
    else
        tfront=true; % otherwise we may need to truncate the front of this
    end
    % if we have a short enough batch of NaNs at the end or the NaNs are
    % not on the end we can either ignore or extrapolate.
    if nanx(length(nanx)) < length(x) || (length(nanx)-(find(diff(nanx)>1,1,'last')+1)) <= w 
        extrap = true; % we can extrapolate
        tend=false; % and we don't need to truncate the end
    else
        tend=true; % we may need to chop this
    end
end

if tfront == true % if we need to truncate the front of our vector
    trunc=1:find(diff(nanx)>1,1,'first');
    x(trunc) = [];
    tind{1}=trunc;
end
if tend == true % if we need to truncate the end of our vector
    trunc=nanx(find(diff(nanx)>1,1,'last')+1):length(x);
    x(trunc)=[];
    tind{2}=trunc;
end

nanind=nanstretch(x); %<-this function simply collects the values 
% if there are no stretches of NaN longer than our set window length
if [nanind{:,1}] < w
    % we can interpolate over all of them
    x=naninterp(x,method,extrap);
else % we need to skip over the large chunks of NaNs
    % first we will need to identify which of the nan stretches need to be
    % skipped
    
    % Now we loop through and get a list of valid indexes over which we can
    % interpolate.
    j=1;
    for i =1:size(nanind,1)
        if nanind{i,1} > w
            if j == 1
                s=1;
            end
           S=nanind{i,2}(1)-1;
           valind{j}=s:S;
           j=j+1;
           s=max(nanind{i,2})+1;
        end
    end
    valind{j}=s:length(x);
    for i = 1:length(valind)
       x(valind{i})=naninterp(x(valind{i}),method,extrap); 
    end
end
end

