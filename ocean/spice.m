function spi = spice(theta,S)

% function spi = spice(theta,S)
% -----------------------------------
% Calculate the state variable spice using the polynomial in Table 1 of
% Flament (2002).
% 
% Tom Connolly, May 2007

% Note that Equation 10 of Flament (2002) has a typo (second exponent
% should be j, not i).

b = [0, 7.7442, -5.85, -9.84, -2.06, 5.1655, 2.034, -2.742, -8.5,...
        1.36, 6.64783, -2.4681, -1.428, 3.337, 7.894, -5.4023, 7.326,...
        7.0036, -3.0412, -1.0853, 3.949, -3.029, -3.8209, 1.0012, 4.7133,...
        -6.36, -1.309, 6.048, -1.1409, -6.76];
k = -[0,1,3,4,4,2,3,4,6,5,3,4,5,5,6,5,6,6,6,6,7,8,7,7,8,10,9,9,9,10];
b = b .* 10 .^ k;

spi = zeros(size(theta));

for i =0:5
    for j=0:4
        bij = b( i*5 + (j+1) );
        sij = bij * (theta .^ i) .* (S-35) .^ j;
        spi = spi + sij;
    end
end