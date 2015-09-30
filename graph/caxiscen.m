function [cax, cvect] = caxiscen(z,rd)

% function cax = caxiscen(rd)
% ---------------------------------
% Center colormap axis around zero, for mapping the two dimensional matrix, Z (input). 
% Round off to the nearest RD (input, optional). Returns a vector of axis limits, CAX (output).
% Can also return CVECT = CAX(1):RD:CAX(2)
% Then call CAXIS(CAX) after PCOLOR, CONTOURF, etc.
%
% Tom Connolly (August, 2007)

cl = caxis;

if nargin == 0
    z = cl; 
end

maxz = max(abs(z));
minz = min(min(z));

cax = [-maxz maxz];


if nargin == 2;
    factor = cax(2)/rd;
    new = ceil(factor)*rd;
    cax = [-new new];
end


caxis(cax);
%cvect = cax(1):rd:cax(2);
