function [headerFormat] = NDBCHeaderFormat(ndbctxt)
%NDBCHeaderFormat This function takes in the text retrieved from the NDBC
%historical data text files and provides an 2xn cell array with the
%variable names and the appropriate format to be used with the textscan()
%function.  CURRENTLY THIS IS ONLY FOR THE STDMET DATA
%   INPUTS
%       ndbctxt - the string of characters retrieved from either urlread or
%       webread of the standard meteorological data from NDBC
%   OUTPUTS
%       headerFormat - an 2xn cell array with the first row containing the
%       variable names and the second with the appropriate formatting
%       string.

% IN ORDER TO ADD OTHER DATA FIELDS THAT MIGHT BE IN OTHER NDBC DATA
% PRODUCTS, SIMPLY ADD THE VARIABLE NAME AND DESIRED FORMAT TO THE CELL
% ARRAY formats.
formats = {'YY','%4d'; 'MM','%2d';'DD','%2d';'hh','%2d';'mm','%2d'; ...
           'WDIR','%3f';'WSPD','%f';'GST','%f';'WVHT','%f';'DPD','%f'; ...
           'APD','%f';'PRES','%f';'ATMP','%f';'WTMP','%f';'DEWP','%f'; ...
           'VIS','%f';'MWD','%3d';'TIDE','%f'};
       
% First we get our data split properly
    d=strsplit(ndbctxt,'\n');
% now we don't need all the rest
    header=d{1}; clear d;
    headerFormat=strsplit(header,'\s*','DelimiterType','RegularExpression');
    for i = 1:length(headerFormat)
        headerFormat{1,i}=NDBCNames(headerFormat{1,i});
        ind = find(strcmp(formats(:,1),headerFormat{1,i}));
        if isempty(ind)==1
           keyboard % we return control to the command window if we can't find anything.
        end
        headerFormat{2,i}=formats{ind,2};
    end
end

