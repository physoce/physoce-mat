function rc = rcrit(nu,sig)

% function rc = rcrit(nu,sig)
% ---------------------------
% Critical r (correlation coefficient), given significance level
% and degrees of freedom.
%
% INPUTS:
% nu - degrees of freedom (N-2)
% sig - significance level (default 0.05)
% 
% OUTPUT:
% rcrit - critical r value
% 
% Values for 0.05 and 0.01 correspond with Appendix E in
% Emery and Thomson (2004) Data Analysis Methods in Physical 
% Oceanography
%
% Tom Connolly (tconnolly@mlml.calstate.edu)

% set default significance level
if nargin == 1
    sig = 0.05;
end

% critical t value
t = tinv(1 - sig/2,nu);

% critical r value
rc = t/sqrt(t.^2+nu);