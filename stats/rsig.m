function p = rsig(r,nu)

% function p = rcrit(r,nu)
% ---------------------------
% p-value for correlation coefficient r, and degrees of freedom nu
%
% INPUTS:
% r - correlation coefficient
% nu - degrees of freedom (N-2)
% 
% OUTPUT:
% p - significance level/p-value
% 
% significance levels of 0.05 and 0.01 correspond with Appendix E in
% Emery and Thomson (2004) Data Analysis Methods in Physical 
% Oceanography
%
% Tom Connolly (tconnolly@mlml.calstate.edu)

% t value
t = r*sqrt(nu)/sqrt(1-r^2);

% significance level
p = 2*(1-tcdf(t,nu));