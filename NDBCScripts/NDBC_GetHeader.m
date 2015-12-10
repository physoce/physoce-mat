function [ headerVals ] = NDBC_GetHeader(stationID,dataProduct)
%NDBC_GetHeader This program is used to collect the current header used for
%NDBC data products.  Variable names have changed over the years and this
%is intended to be used in conjunction with another function (NDBCNames)
%to ensure the right values are saved in the right location when data files
%being collected include old names.
%   INPUTS
%       stationID - the NDBC numerical ID of the data buoy whose data is
%       being queried.
%       dataProduct - A string representing the NDBC data product being 
%       collected. CURRENTLY THESE FUNCTIONS ONLY HAVE BEEN CHECKED FOR THE 
%       HISTORICAL STDMET DATA PRODUCT.
%`  OUTPUTS
%       headerVals - a cell array of the variable names in the data product
%       being returned.  If the header includes a line with units these
%       will be returned as a second row in the cell array.
%
% Created by C. Ryan Manzer, Moss Landing Marine Labs - 10/15/2015
%-------------------------------------------------------------------------

base_url = 'http://www.ndbc.noaa.gov/view_text_file.php';
station_url = sprintf('filename=%dh',stationID);
data_dir = sprintf('dir=data/historical/%s/', dataProduct);

% Some data buoys may not have any current data files so we need to loop 
% back to look for the most recent data file
for i = year(date)-1:-1:year(date)-20
        full_url = sprintf('%s?%s%d.txt.gz%c%s',base_url,station_url,i,'&',data_dir);
        d=urlread(full_url);
        if strcmp('Unable to access data file',d)
            % There is no data here
        else
            headerVals{1,1}='DateTime';
            headerVals{2,1}='YYMMDDhhmm';
            k=1;
            d=strsplit(d,'\n'); %splitting our file by newline
            if strcmp(d{1}(1),'#') % if our file has variable names
               varnames=strsplit(d{1},'\s*','DelimiterType','RegularExpression'); % this will produce a cell array(1xn) of variable names
               if strcmp(d{2}(1),'#') % if it includes a second line this is usually units
                   varunits = strsplit(d{2},'\s*','DelimiterType','RegularExpression');
               else
                   varunits = [];
               end
               for j = 1:length(varnames) % looping through the names provided
                   val=NDBCNames(varnames{j});
                  if isempty(val)==0 % making sure it's a valid variable (this will exclude the date/time info!)
                      k=k+1;
                      headerVals{1,k}=val; clear val;
                      if isempty(varunits)==0
                          headerVals{2,k}=varunits{j};
                      end
                  end
               end
               return
            else
                headerVals=[];
            end            
        end
end

