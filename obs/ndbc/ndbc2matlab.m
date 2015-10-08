function  [d,d1,d2]=ndbc2matlab(stname,yrstart,yrend,matfile); 
%[d,d1,d2]=ndbc2matlab(stname,yrstart,yrend,matfile); 
%saves new mat-file as "stname.mat"
%from S Lentz

zwnd=5;%default value
lat=nan;
lon=nan;
%get station information
[stida,sitea,lata,lona,wdepa,zwnda,ztmpa,zssta,yrsta,yrenda]=textread('MAB_stations.txt','%s %s %f %f %f %f %f %f %d %d %*[^\n]');
for k=1:length(stida);stn=stida{k}; j(k)=strcmpi(stname,stn);end;jc=find(j==1);
if (length(jc)==1);
    lat=lata(jc);lon=lona(jc);zwnd=zwnda(jc);site=sitea(jc,:);wd=wdepa(jc);ztmp=ztmpa(jc);zsst=zssta(jc);
    if (nargin==1);yrstart=yrsta(jc);yrend=yrenda(jc);end;
else
    disp('no information on lat, lon or anemometer height');
end;


clear wnd gust wvht wvpp wvap wvdr ap at sst dewp vis
%Add to an existing mat file?
if (nargin==4);
  eval(['load ',matfile,'.mat']);
  jdold=jd; 
  if (exist('wnd')); wndold=wnd; else; wndold=nan*jdold; end;
  if (exist('gust')); gustold=gust; else; gustold=nan*jdold; end;
  if (exist('wvht')); wvhtold=wvht; else; wvhtold=nan*jdold; end;
  if (exist('wvpp')); wvppold=wvpp; else; wvppold=nan*jdold; end;
  if (exist('wvap')); wvapold=wvap; else; wvapold=nan*jdold; end;
  if (exist('wvdr')); wvdrold=wvdr; else; wvdrold=nan*jdold; end;
  if (exist('ap')); apold=ap; else; apold=nan*jdold; end;
  if (exist('at')); atold=at; else; atold=nan*jdold; end;
  if (exist('sst')); sstold=sst; else; sstold=nan*jdold; end;
  if (exist('dewp')); dewpold=dewp; else; dewpold=nan*jdold; end;
  if (exist('vis')); visold=vis; else; visold=nan*jdold; end;
end;

 
%if (nargin==2); kyr=yrst; end;%year string 2nd input 
%if (nargin==3); kyr=yrst:yrend; end; 
kyr=yrstart:yrend;
nyr=length(kyr); 
nl=24.*400;%number of lines to read (needs to be larger than max) 

%todays date to determine if need to load monthly data for this year
date_today=gregorian(matday2jd(datenum(date)));
year_today=date_today(1);
if (yrend==year_today);nyr=nyr-1;end;
x=[];

if (nyr>0);
for k=1:nyr;    
 filename=[stname,'h',num2str(kyr(k)),'.txt'] 
 URL=['http://www.ndbc.noaa.gov/view_text_file.php?filename=',filename,'.gz&dir=data/historical/stdmet/'];
 urlwrite(URL, filename); 
 fid=fopen(filename);
 
 if (kyr(k)<2000); 
     A=fscanf(fid,'%s',[16,1]); 
     d=fscanf(fid,'%g',[16,inf]);d=d.'; 
 end; 
 if(kyr(k)==2000) 
      
     %find where number of columns changes 
      j=0;jeof=0;while(jeof~=1);j=j+1;[tline]=fgets(fid);n(j)=length(tline);jeof=n(j);end; 
      j=find(n(2:end)==max(n));
      fclose(fid); 
      fid=fopen(filename); 
     A=fscanf(fid,'%s',[17,1]); 
     if (length(j)>0);
         n=j(1)-1;  
        d1=fscanf(fid,'%g',[16,n]);d1=d1.'; 
        d2=fscanf(fid,'%g',[17,inf]);d2=d2.'; 
        d=[d1;d2(:,1:16)]; 
     else
         d=fscanf(fid,'%g',[16,inf]);d=d.';
     end
   end; 
 if (kyr(k)>2000);
    %figure out how many header lines and how many columns
    A=fgetl(fid);
    variables=textscan(A,'%s');
    nc=length(variables{:});
    %read second header line if first character is #
    if (A(1)=='#');A=fgetl(fid);end;
    d=fscanf(fid,'%g',[nc,inf]);
    if (nc==17);d=d(1:16,:).';end;
    if (nc==18);d=d([1:4,6:17],:).';end;%leave out minutes column and tide column
 end; 

 fclose(fid);
  
%    if (k==1); 
%     x=d; 
%    else 
    x=[x;d]; 
%    end; 
 end;
end;
 
 %add this years data if requested
 mon=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
 if (yrend==year_today);
     nmnth=date_today(2);
    for k=1:nmnth;    
        filename=[stname,num2str(k),num2str(year_today),'.txt']; 
        URL=['http://www.ndbc.noaa.gov/view_text_file.php?filename=',filename,'.gz&dir=data/stdmet/',mon(k,:),'/']
        urlwrite(URL, filename); 
        fid=fopen(filename);
 
        %figure out how many header lines and how many columns
        A=fgetl(fid);
        variables=textscan(A,'%s');
        nc=length(variables{:});
        %read second header line if first character is #
        if (A(1)=='#');A=fgetl(fid);end;
        d=fscanf(fid,'%g',[nc,inf]);
        if (nc==17);d=d(1:16,:).';end;
        if (nc==18);d=d([1:4,6:17],:).';end;%leave out minutes column and tide column


        fclose(fid);
%   
%         if (k==1&nyr==0); 
%             x=d; 
%         else 
            x=[x;d]; 
%         end; 
    end; 
 end;
 
%convert data 
% yr=x(:,1);j=find(yr<100);yr(j)=1900+yr(j); 
% jb=find(yr<yrstart|yr>yrend);
% x(jb,:)=[];%discard times outside range
yr=x(:,1);j=find(yr<100);yr(j)=1900+yr(j); 
mon=x(:,2); 
day=x(:,3); 
hour=x(:,4);
jd=julian(yr,mon,day,hour); 
jb=find(jd<julian(yrstart,1,1,0)|jd>julian(yrend+1,1,1,0));
jd(jb)=[];
x(jb,:)=[];
%find redundant data 
[jds,js]=sort(jd);
jg=find(diff(jds)>0);
js=js(jg);
jd=jd(js);
x=x(js,:);

 
wdir=x(:,5);j=find(wdir==999);wdir(j)=j*nan; 
wspd=x(:,6);j=find(wspd==99.0);wspd(j)=j*nan; 
%convert from a meteorological convention  
% 0 deg wind from north, 90 wind from east 
%to an oceanographic convention 
% 0 deg wind toward east (positive real) 
%90 deg wind toward north (positive imag) 
if (nargin==4);
    jold=find(jdold<jd(1));
    jd=[jdold(jold);jd];
    wnd=[wndold(jold);wspd.*exp(-i.*(wdir-270).*pi./180)]; 
    gust=[gustold(jold);x(:,7)];j=find(gust==99.0);gust(j)=j*nan; 
    %conversion of wave height from feet to meters
    wvht=[wvhtold(jold);x(:,8)];j=find(wvht>=90.0|wvht==0);wvht(j)=j*nan; 
    wvpp=[wvppold(jold);x(:,9)];j=find(wvpp==99.0|wvpp==0);wvpp(j)=j*nan; 
    wvap=[wvapold(jold);x(:,10)];j=find(wvap==99.0|wvap==0);wvap(j)=j*nan; 
    wvdr=[wvdrold(jold);x(:,11)];j=find(wvdr==999);wvdr(j)=j*nan; 
    ap=[apold(jold);x(:,12)];j=find(ap>1200|ap<800);ap(j)=j*nan; 
    at=[atold(jold);x(:,13)];j=find(at>100|at<-100);at(j)=j*nan; 
    sst=[sstold(jold);x(:,14)];j=find(sst>100|sst<-10);sst(j)=j*nan; 
    dewp=[dewpold(jold);x(:,15)];j=find(dewp==999.0);dewp(j)=j*nan; 
    vis=[visold(jold);x(:,16)];j=find(vis==99.0);vis(j)=j*nan;
else
    wnd=wspd.*exp(-i.*(wdir-270).*pi./180); 
    gust=x(:,7);j=find(gust==99.0);gust(j)=j*nan; 
    wvht=x(:,8);j=find(wvht>=90.0|wvht==0);wvht(j)=j*nan; 
    wvpp=x(:,9);j=find(wvpp==99.0|wvpp==0);wvpp(j)=j*nan; 
    wvap=x(:,10);j=find(wvap==99.0|wvap==0);wvap(j)=j*nan; 
    wvdr=x(:,11);j=find(wvdr==999);wvdr(j)=j*nan; 
    ap=x(:,12);j=find(ap>1200|ap<800);ap(j)=j*nan; 
    at=x(:,13);j=find(at>100|at<-100);at(j)=j*nan; 
    sst=x(:,14);j=find(sst>100|sst<-10);sst(j)=j*nan; 
    dewp=x(:,15);j=find(dewp==999.0);dewp(j)=j*nan; 
    vis=x(:,16);j=find(vis==99.0);vis(j)=j*nan;
end;
j=find(wvdr>360);wvdr(j)=wvdr(j)-360;
j=find(wvdr<0);wvdr(j)=wvdr(j)+360;
%toss out empty array variables
 if (sum(~isnan(wnd))==0);clear wnd ws;end
 if (sum(~isnan(gust))==0);clear gust;end 
 if (sum(~isnan(wvht))==0);clear wvht;end 
 if (sum(~isnan(wvpp))==0);clear wvpp;end 
 if (sum(~isnan(wvap))==0);clear wvap;end 
 if (sum(~isnan(wvdr))==0);clear wvdr;end 
 if (sum(~isnan(ap))==0);clear ap;end 
 if (sum(~isnan(at))==0);clear at;end 
 if (sum(~isnan(sst))==0);clear sst;end 
 if (sum(~isnan(dewp))==0);clear dewp;end 
 if (sum(~isnan(vis))==0);clear vis;end 

 
 %documentation 
 README=['VARIABLES:                                            ';... 
         'jd   - julian day                                     ';... 
         'station - NDBC station number                         ';... 
         'lat,lon  - station latitude and longitude             ';... 
         'wnd  - wind velocity (m/s), real component eastward   ';... 
         '                        imaginary component northward ';... 
         'gust - peak 5 sec wind speed (m/s)                    ';... 
         'wvht - significant wave height (m) (ave highest 1/3)  ';... 
         'wvpp - peak wave period (sec)                         ';... 
         'wvap - average wave period (sec)                      ';... 
         'wvdr - wave direction (degrees rel. North)            ';... 
         'ap   - barometric pressure (hPa)                      ';... 
         'at   - air temperature (degrees Celsius)              ';... 
         'sst  - sea surface temperature (deg. C)               ';... 
         'dewp - dew point temperature (deg. C)                 ';... 
         'vis  - visibility (km)                                ';...
         'zwnd - height of wind measurement (m)                 ';...
         'zat  - height of air and dewpt temperatures (m)       ']; 
               
 
clear d day filename x hour j k kyr mon nl nyr wspd wdir yr jeof 
clear yrend d1 d2 A fid jb jds js jg ans n yrst yrstart
clear apold atold dewpold gustold jdold jold sstold visold wndold
clear wvapold wvdrold wvhtold wvppold station matfile
clear stida sitea lata lona zwnda k jc nc URL date_today stn tline
clear wdepa yrenda yrsta year_today zssta ztmpa
eval(['save ',stname,'.mat']); 