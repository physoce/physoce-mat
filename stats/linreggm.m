function coeff = linreggm(x,y)

% function [m,b,m2,b2] = linreggm(x,y)
% ----------------------------------------
% Geometric mean, or Type II, linear regression (Ricker, 1973; Laws and
% Archie, 1981).  Returns coeff where y = coeff(1)*x + coeff(2)

% Take out NaNs
xi = find(~isnan(x));
yi = find(~isnan(y));
alli = intersect(xi,yi);
x = x(alli);
y = y(alli);

% Least-squares regression
p = polyfit(x,y,1);
m2 = p(1);
b2 = p(2);

% Geometric mean (Type II) regression
xsqsum = sum((x-mean(x)).^2);
ysqsum = sum((y-mean(y)).^2);
m = sign(m2)*sqrt(ysqsum*xsqsum.^-1);
b = mean(y) - m*mean(x);

coeff(1) = m;
coeff(2) = b;
coeff(3) = m2;
coeff(4) = b2;