function fillndbcgap(in_file,out_file)
% fillndbcgap(in_file,out_file)
% 
% Fills gaps in an NDBC time series (made with ndbc2matlab.m)
% with NaNs, and saves in a new file.
%
% Requires function fillgapwithnan.m
%
% Tom Connolly


load(in_file);
tmp.jd = jd;

[jd,sst] = fillgapwithnan(tmp.jd,sst);
if exist('wnd','var')
    [jd,wnd] = fillgapwithnan(tmp.jd,wnd);
    [jd,gust] = fillgapwithnan(tmp.jd,gust);
    [jd,ap] = fillgapwithnan(tmp.jd,ap);
    [jd,at] = fillgapwithnan(tmp.jd,at);
end
if exist('wvht','var')
    [jd,wvht] = fillgapwithnan(tmp.jd,wvht);
    [jd,wvpp] = fillgapwithnan(tmp.jd,wvpp);
    [jd,wvap] = fillgapwithnan(tmp.jd,wvap);
    [jd,wvdr] = fillgapwithnan(tmp.jd,wvdr);
end
if exist('dewp','var')
    [jd,dewp] = fillgapwithnan(tmp.jd,dewp);
end

clear tmp
save([out_file])