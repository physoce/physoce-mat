function umoll = O2mll2umoll(mll)

% function umolL = O2mll2umoll(mll)
% ------------------------------------------
% Converts O2 units from ml/l to umol/L.
% Tom Connolly
% Approximate as of 9/2/2007

umoll = 10^3*mll /(22.4); % Convert from ml/l to umol/l using ideal gas law