function h = zeroline(axs,linetype)

% ZEROLINE
% ----------------
% ZEROLINE  Plots a line across an axis marking zero.
% 
% ZEROLINE(AXS)  AXS can be 'x', 'y' or 'xy', like ZEROLINE('x'), which 
%                                  makes the line go the extent of the x
%                                  axis. Default is 'x'.
% ZEROLINE(AXS,LINETYPE)  Also allows specification of a linestyle and
%                                                       color. Default is 'k--'.
% H =  ZEROLINE  Returns the handle given by the

% Set defaults
if nargin == 0
    linetype = 'k--';
    axs = 'x';
elseif nargin == 1
    linetype = 'k--';
end

if axs == 'x';
    xl = xlim;
    hold on, h = plot(xl',zeros(size(xl))',linetype); hold off
elseif axs == 'y'
    yl = ylim;
    hold on, h = plot(zeros(size(yl))',yl',linetype); hold off
elseif axs == 'xy';
    xl = xlim;
    yl = ylim;
    hold on, h = plot(xl',zeros(size(xl))',linetype); hold off
    hold on, h = plot(zeros(size(yl))',yl',linetype); hold off
else
    error('Need to specify x, y or xy (strings) for AXS') 
end