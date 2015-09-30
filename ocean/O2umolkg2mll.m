function mll = O2umolkg2mll(umolkg,density)

% function mll = O2umolkg2mll(umolkg,density)
% --------------------------------------------------------
% Converts O2 units from umol/kg to ml/l.
% density (of seawater) in units of kg/m^3 
% density can be a vector same size as umolkg or a scalar value
%
% Tom Connolly

mlkg = 10^-3 * umolkg * 22.4; % Convert to ml/kg
mll = mlkg .* density * 10^-3; % Convert to ml/l