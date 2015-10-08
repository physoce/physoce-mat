function [tout,xout] = fillgapwithnan(tin,xin)

% function [tout,xout] = fillgapwithnan(tin,xin)
% Fills gaps in a time series with NaNs
%
% tin should be a column vector
% xin can be a 2-D matrix with the same number of rows as tin
%
% Note that this function is designed for use with time series that
% are in units of days, with minimum time step greater than one
% second.
%
% Tom Connolly

if min(diff(tin)) < 1/86400
    error('minimum time step cannot be less than 1 second!')
end
tin  = datenum(datevec(tin)); % rounds off to nearest second

dt = mode(diff(tin));
tout1 = tin(1):dt:tin(end); % gives best estimate of # of time steps
nt = length(tout1);

tout = linspace(tin(1),tin(end),nt); % gives closest times to tin
tout = datenum(datevec(tout)); % rounds off to nearest second

[tf, ii] = ismember(tin, tout);

xout = nan(length(tout),size(xin,2));
xout(ii) = xin;