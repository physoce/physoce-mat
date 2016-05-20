function [v,lonv,latv,xv] = vg_coast(T,S,pr,lon,lat,reflevel)

% [v,lonv,latv,xv] = vg_coast(T,S,pr,lon,lat,reflevel)
% ----------------------------------------------------
% Calculate geostrophic velocity perpendicular to a coastal transect. Uses
% extrapolation method of Reid and Mantyla (1976) for stations shallower than
% the reference level.
%
% INPUTS:
% T - in-situ temperature [deg C] - 2d array (m x n)
% S - salinity [psu] - 2d array (m x n)
% pr - pressure [dbar] - 1d vector (m x 1)
% lon - longitude - 1d vector (n x 1)
% lat - latitude - 1d vector (n x 1)            
% reflevel - reference level [dbar] - scalar (1 x 1)
%
% OUTPUT:
% v - velocity [cm/s] - 2d array (m x (n-1))
% lonv - longitude - 1d vector ((n-1)x1)
% latv - latitude - 1d vector ((n-1)x1)
% xv - distance along transect [km] - 1d vector (1 x (n-1))
%
% Sign convention:
% If transect is oriented west to east, positive velocity is northward.
%
% Assumptions:
% * transect is offshore (1st column) --> onshore (last column)
% * the maximum cast depth increases or decreases monotonically (no canyons, seamounts)
% * the two deepest stations have pressure greater than or equal to reflevel
% * f does not change significantly along the transect
%
% Requires: seawater toolbox

% Tom Connolly and Riley Linder

% make sure vectors are columns
if size(pr,2) > size(pr,1)
    pr = pr';
    if size(pr,2) > 1
        error('pressure must be a vector');
    end
end
if size(lon,2) > size(lon,1)
    lon = lon';
    lat = lat';
    if size(lon,2) > 1
        error('lon,lat must be vectors');
    end
end

lonv = 0.5*(lon(1:end-1)+lon(2:end));
latv = 0.5*(lat(1:end-1)+lat(2:end));

refi = find(pr==reflevel);
if isempty(refi)
    error('pressure vector must include reference level')
end

V = NaN*zeros(refi,size(S,2));
vec = length(lon);
p = pr (1:refi);
pr = pr (1:refi); 
Ssec = S(1:refi,:);
Tsec = T(1:refi,:);
svan = sw_svan(Ssec,Tsec,p); % specific volume anomaly

%%%Create distance variable for contour plot%%%
distm        = 1000*sw_dist(lat,lon,'km');
dtemp        = cumsum(distm);     %Distance with zero offshore
dtemp        = [0;dtemp];
d            = dtemp-dtemp(end);  %Distance with zero onshore
temp_dga     = (d(1:end-1)+d(2:end))/2;
dga          = [temp_dga]/(1e+003); 

DEG2RAD = pi/180;
RAD2DEG = 180/pi;
OMEGA   = 7.292e-5;  % Angular velocity of Earth  [radians/sec]
f       = 2*OMEGA*sin( (lat(1))*DEG2RAD ); % TO DO - variable f

m           = length(p);
n           = size(S,2);
db2Pascal   = 1e4;

% specific volume anomaly (svan)
mean_svan   = 0.5*(svan(2:m,:) + svan(1:m-1,:) ); 

% integrate svan to find geopotential anomaly (ga)
delta_ga    = (mean_svan.*db2Pascal.*repmat(diff(p),[1 n]));   
flipdelta_ga  = flipud (delta_ga);
prega         = cumsum(flipdelta_ga);
ga            = [flipud(prega);zeros(1,vec)];

for n=2:length(lon)
    if  max(find(isfinite(Tsec(:,n))))==refi;
        lf   =  (distm(n-1).*f);
        vel  = (ga(:,n)-ga(:,n-1)) ./ (lf);
        ga_all(:,[n-1:n])= ga(:,[n-1:n]);
        vel_all (:,n-1)    =  vel(:);
        good               =  find(isfinite(delta_ga(:,n)));
        depth_temp         =  max(good);
        depth_all (:,n-1)  =  depth_temp(:);
    else  max(find(isfinite(Tsec(:,n))))<refi;
        %%%extrapolation%%%
        good =  find(isfinite(delta_ga(:,n)));  
        newreflevel      =  max(good)+1;

        ref_delta_ga     =  ([delta_ga(1:newreflevel,n)]); % *********
        newref1          =  ga_all(newreflevel,n-2);
        newref2          =  ga_all(newreflevel,n-1);
        refdist          =  1000*sw_dist([lat(n-2),lat(n-1)],[lon(n-2),lon(n-1)],'km');
        refslope         =  (newref2 - newref1) ./ (refdist);
        extrapdist          =  1000*sw_dist([lat(n-1),lat(n)],[lon(n-1),lon(n)],'km');
        extrapval        =  ((refslope) * extrapdist) + newref2;
        ref_delta_ga (newreflevel)    =  extrapval;  % *****

        flip_ref_delta_ga=  flipud(ref_delta_ga);
        pre_ref_ga       =  cumsum([flip_ref_delta_ga]);
        unflip_ref_ga    =  [flipud(pre_ref_ga)];
        ga_final         =  NaN*ones([reflevel,1]);
        ga_final(1:newreflevel,:) =  [unflip_ref_ga];

        new_ga           =  ga_final(1:newreflevel,:);
        pre_column_ga    =  NaN*ones([refi,1]);
        pre_column_ga(1:newreflevel) =  [new_ga];
        ga_all(:,n)     =  pre_column_ga;   %store all geostrophic anomaly values

        %%geostropic velocity
        lf               =  (extrapdist*f);
        vel              = (ga_all(:,n)-ga_all(:,n-1))/(lf);
        vel_all (:,n-1)  =  vel(:);          %store all velocity values

        dga_all (:,n-1)  =  dga(:);
        dga_all_plot     =  dga_all(:,end).';
        dga_all_plot2    =  [dga_all_plot,0];

        depth_temp       =  max(good);
        depth_all (:,n-1)=  depth_temp(:);
        depth_all2       =  [depth_all,reflevel];
    end

end 
GA = ga_all;
xv = dga_all_plot;
v = vel_all*100;  % cm/s
