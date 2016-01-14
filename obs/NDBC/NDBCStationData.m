function [ station_data ] = NDBCStationData( url )
%NDBCStationData - This function gathers data about the NDBC station by
%analyzing the text of the station URL passed in.  It returns a cell matrix
%with this information
%   INPUTS
%       url - the url for the NDBC station website
%   OUTPUTS
%       station_data - a cell matrix of strings with station information
%
% by C. Ryan Manzer 1/14/2016  Moss Landing Marine Labs
%--------------------------------------------------------------------------
if ~ischar(url)
   disp('The url must be provided as a string.')
   exit
end
% Defining the values we will be looking for (in addition to GPS
% coordinates).  If additional data is desired, adding the terms here is
% how this script should be modified.
data_fields=cell(1);
data_fields{1}='Site elevation';
data_fields{2}='Air temp height';
data_fields{3}='Anemometer height';
data_fields{4}='Barometer elevation';
data_fields{5}='Sea temp depth';
data_fields{6}='Water depth';
data_fields{7}='Watch circle radius';

station_data=cell(1); % instantiating our cell matrix
sdInd=1; % starting our station_data index

% First we read in the full text of the URL as a string.
urldata=urlread(url); % <- This returns a string of all the 

% We only want a small portion of this text and thankfully NDBC's current
% web design is such that it makes isolating this text fairly easy.  We
% will use regular expressions to find the index values where our desired
% text starts and ends.
regpattern='<p><b>.*<br />\s*\t*\n*</p>';
start=regexpi(urldata,regpattern); % regexp functions in MATLAB default to
                                   % returning index values where patterns
                                   % are matched.
regpattern='<br />\s*\t*\n*</p>';
stop=regexpi(urldata,regpattern); % matching the end
urldata=urldata(start:stop);
%Now let's get the location of this station
% First we create a regular expression pattern that will match latitude and
% longitude.
coord_pattern='[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\s?[NSEW]';
% Now we apply the regular expression and get a cell array of matching
% terms from the url text.
matchs=regexp(urldata,coord_pattern,'match');
% Looping through the matches to our pattern and assigning them to ou
for i = 1:length(matchs)
    if ~isempty(cell2mat(strfind(matchs(i),'N'))) ||...
            ~isempty(cell2mat(strfind(matchs(i),'S')))
        station_data{sdInd,1}='Latitude';
        station_data{sdInd,2}=matchs{i};
        sdInd=sdInd+1;
    elseif ~isempty(cell2mat(strfind(matchs(i),'W'))) ||...
            ~isempty(cell2mat(strfind(matchs(i),'E')))
        station_data{sdInd,1}='Longitude';
        station_data{sdInd,2}=matchs{i};
        sdInd=sdInd+1;
    end
end
% Now we look for the rest of our site data
for i = 1:length(data_fields)
   data_term=data_fields{i};
   % this will provide the index where this term starts, we need to find
   % the next term after it.  Thankfully, NDBC bolds the terms and then has
   % a line break after the data.  We will use this to isolate the
   % information we want.
   match=regexpi(urldata,data_term);
   if iscell(match)
       match=cell2mat(match);
   end
   if ~isempty(match)
       start=match(1);
       % Now we get the index numbers of the HTML tags that bound the data
       % we want to extract
       bmatch=regexpi(urldata(start:length(urldata)),'</b>');
       brmatch=regexpi(urldata(start:length(urldata)),'<br />');
       if ~isempty(bmatch) && ~isempty(brmatch)
           station_data{sdInd,1}=data_term;
           station_data{sdInd,2}=urldata(bmatch(1)+length('</b>')+start:start+brmatch(1)-2);
           sdInd=sdInd+1;
       end
   end
end
end

