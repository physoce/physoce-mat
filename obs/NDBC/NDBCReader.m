function [ buoystruct ] = NDBCReader(stationID,years,months)
%NDBCReader fetches standard meteorologica data from the NDBC data archives
%for a specific buoy and and time frame specified
%   INPUTS
%       stationID - the buoy station name or number.
%       years - this should be a vector of the year values for which the
%               user wants to collect data (eg, [2009, 2010, 2011, 2012].
%               Once a year's data is complete NDBC stores it as a single 
%               .txt file. Enter an empty array if no yearly data is
%               desired.
%       months - this should be a NUMERICAL vector of months OF THE 
%                CURRENT YEAR for which the user wants standard 
%                meterological data.  Enter an empty array if no monthly 
%                data is desired.
%       IF BOTH YEARS AND MONTHS ARE PROVIDED IT WILL RETURN TOTAL YEAR
%       DATA FOR YEARS SPECIFICED AS WELL AS MONTHLY DATA FOR CURRENT YEAR
% Created by C. Ryan Manzer - Moss Landing Marine Labs 10.8.2015
%--------------------------------------------------------------------------

% First we check to make sure we have what we need to be successful
neededFiles = {};
if exist('NDBCNames.m','file')~=2
    neededFiles={'NDBCNames.m'};
end
if exist('NDBCHeaderFormat.m','file')~=2
    neededFiles=vertcat(neededFiles,{'NDBCHeaderFormat.m'});
end
if isempty(neededFiles)==0
    disp(['NDBCReader depends on the following functions.  ' ...
        'These functions are either not installed or not in your path.  ' ...
        'Please fix this and try again.'])
    disp('Missing Functions:')
    disp(neededFiles)
    buoystruct=[];
    return
end
%-------------------------------------------------------------------------
% Now we start our function
%-------------------------------------------------------------------------
NoDataMonths=[]; NoDataYears=[];
buoystruct=struct([]); % creating our empty structure to start with
% our base url, how all NDBC data is accessed.  NDBC uses PHP scripts with
% the GET data access method.  This allows us to pass query values to the
% back end server through the URL.
base_url='http://www.ndbc.noaa.gov/view_text_file.php?'; 
% the data directories for yearly and monthly data
data_dir{1} = 'dir=data/historical/stdmet/'; % yearly data directory
data_dir{2} = 'dir=data/stdmet/'; %monthly directory.  The 3 letter month
                                  %abbreviation will need to be appended to
                                  %this.
% creating a handy cell matrix of month abreviations.
monthAbv={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov' ...
    'Dec'};
buoystruct(1).time=[]; % creating our first buoy structure field
%-------------------------------------------------------------------------
% Minor tweak to deal with the fact we want to accept both strings and
% numbers as station IDs (NOAA buoys usually use numbers while shore
% stations may have alphabetic characters).
%-------------------------------------------------------------------------
% We need to convert our stationID into characters if it is numeric
if isnumeric(stationID) == 1
   stationID=num2str(stationID);
else
   stationID=lower(stationID); %NDBC uses lower case characters in their file names.
end
%--------------------------------------------------------------------------
% Getting annual data summaries
%--------------------------------------------------------------------------
% If we have a years vector
if isempty(years)==0
    % Determining how best generate our buoy data fields and appending the
    % units, if we have them.
    if max(years)>=2007
        full_url=sprintf('%sfilename=%sh%d.txt.gz&%s',...
           base_url,stationID, max(years),data_dir{1});
       try
        d=webread(full_url); % This gives us a single string with all the data
       catch
           fprintf('Data is not available for %d',max(years));
           return
       end
       d=strsplit(d,'\n'); % now we have it split by line in a cell array
       l1=strsplit(d{1},'\s*','DelimiterType','RegularExpression'); % getting the first line (variables)
       l2=strsplit(d{2},'\s*','DelimiterType','RegularExpression'); % getting second line (sometimes variable units
       % we need to find out where the date/time values end so we know
       % where our variables of interest begin.
       varstart = find(strcmp(l1,'ss'));
       if isempty(varstart) == 1
           varstart = find(strcmp(l1,'mm'));
           if isempty(varstart)== 1
               varstart=find(strcmp(l1,'hh'));
                if isempty(varstart)== 1
                    varstart=find(strcmp(l1,'DD')); 
                end
           end
       end
       varstart = varstart+1; % varstart is currently set to the last date/time field so we increment by 1
       for j = varstart:length(l2)
           buoystruct.(l1{j}).units=l2{j}; % assigning the variable names as fields
                                                % (except time which we will convert) to our structure
                                                % and appending the units
                                                % as attributes.
          buoystruct.(l1{j}).data=[]; % making an empty vector for our data
       end
    else full_url=sprintf('%sfilename=%dh%d.txt.gz&%s',...
           base_url,stationID, max(years),data_dir{1});
       try
        d=webread(full_url); % This gives us a single string with all the data
       catch
           fprintf('Data is not available for %d',max(years));
           return
       end
       d=strsplit(d,'\n'); % now we have it split by line in a cell array
       header=strsplit(d{1},'\s*','DelimiterType','RegularExpression');
       % we need to find out where the date/time values end so we know
       % where our variables of interest begin.
       varstart = find(strcmp(header,'ss'));
       if isempty(varstart) == 1
           varstart = find(strcmp(l1,'mm'));
           if isempty(varstart)== 1
               varstart=find(strcmp(l1,'hh'));
                if isempty(varstart)== 1
                    varstart=find(strcmp(l1,'DD')); 
                end
           end
       end
       varstart=varstart+1;
       for j = varstart:length(header)
          buoystruct(header{j}).data=[]; % creating empty fields
       end
    end
    for i = 1:length(years)
        
        if years(i)>=2007 % determining how many lines are in our header
            hl=2;         %NDBC changed their format starting in 2007 to
        
        else              % include the units for each of their variables.
            hl=1;
        end
       full_url=sprintf('%sfilename=%sh%d.txt.gz&%s',...
           base_url,stationID, years(i),data_dir{1});
       %disp(full_url) <- this produces working urls!
       try 
        d=webread(full_url); % This gives us a single string with all the data
        if strcmp(d,'Unable to access')
           NoDataYears=vertcat(NoDataYears, years(i));
           continue
        end
       catch
           NoDataYears=vertcat(NoDataYears, years(i));
           continue
       end
       
       % The function below will split the text up into a cell array of
       % vectors for each of the specified formats.  First we make sure we
       % associate all the variable names with the right data vectors!
       ts=NDBCHeaderFormat(d);
       strFormat = '';
       for k = 1:length(ts)
          strFormat=[strFormat ' ' ts{2,k}]; 
       end
       strFormat=strtrim(strFormat);
       ts(2,:)=textscan(d,strFormat,'HeaderLines',hl,'Delimiter','\t');
       %The first five cells contain the year, month, day, hour, and minute
       %respectively.  We will build these into a matlad datetime vector.
       %This function requires either just Y D M or Y D M H m s so we will
       %have to be tricky there.  Also some NDBC stdMet txt files contain a
       %minute vector and some do not so we will have to be careful of
       %that.
       t=buoystruct.time;
       Yind=find(strcmp(ts(1,:),'YY'));Mind=find(strcmp(ts(1,:),'MM'));
       Dind=find(strcmp(ts(1,:),'DD'));Hind=find(strcmp(ts(1,:),'hh'));
       mInd=find(strcmp(ts(1,:),'mm'));
       if isempty(mInd)==0
           t = vertcat(t, datetime(ts{2,Yind},ts{2,Mind},ts{2,Dind},ts{2,Hind},ts{2,mInd},zeros(size(ts{2,1}))));
       else
           t = vertcat(t, datetime(ts{2,Yind},ts{2,Mind},ts{2,Dind},ts{2,Hind},zeros(size(ts{2,1})),zeros(size(ts{2,1}))));
       end
       buoystruct.time=t; clear t;
       fnames = fields(buoystruct); % getting a cell array of our field names
       for j = 2:length(fnames)
          ind=find(strcmp(ts(1,:),fnames{j}));
          bd = buoystruct.(fnames{j}).data;
          bd=vertcat(bd, ts{2,ind});
          buoystruct.(fnames{j}).data = bd; clear bd;
       end
    end
end
%--------------------------------------------------------------------------
%  GETTING MONTHLY DATA SUMMARIES
%--------------------------------------------------------------------------
if isempty(months)==0
    if isempty(buoystruct)==1
       full_url=sprintf('%sfilename=%s%d%d.txt.gz&%s%s/',...
           base_url,stationID,months(1),year(date) ,data_dir{2},monthAbv{1});
       d=webread(full_url); % This gives us a single string with all the data
       d=strsplit(d,'\n'); % now we have it split by line in a cell array
       l1=strsplit(d{1},'\s*','DelimiterType','RegularExpression'); % getting the first line (variables)
       l2=strsplit(d{2},'\s*','DelimiterType','RegularExpression'); % getting second line (sometimes variable units
       for j = 6:length(l2)
           buoystruct.(l1{j}).units=l2{j}; % assigning the variable names as fields
                                                % (except time which we will convert) to our structure
                                                % and appending the units
                                                % as attributes.
       end 
    end
    for i = 1:length(months)
        
       full_url=sprintf('%sfilename=%s%d%d.txt.gz&%s%s/',...
           base_url,stationID,months(i),year(date) ,data_dir{2},monthAbv{i});
       %disp(full_url) <- this produces working urls!
        d=webread(full_url); % This gives us a single string with all the data
        if strcmp(d,'Unable to access')
           NoDataMonths=vertcat(NoDataMonths, months(i));
           continue
       end
        
        ts=NDBCHeaderFormat(d);
        strFormat = '';
        for k = 1:length(ts)
           strFormat=[strFormat ' ' ts{2,k}]; 
        end
        strFormat=strtrim(strFormat);
        ts(2,:)=textscan(d,strFormat,'HeaderLines',hl,'Delimiter','\t');
        
        %The first five cells contain the year, month, day, hour, and minute
       %respectively.  We will build these into a matlad datetime vector.
       %This function requires either just Y D M or Y D M H m s so we will
       %have to be tricky there.
       t=buoystruct.time;
       Yind=find(strcmp(ts(1,:),'YY'));Mind=find(strcmp(ts(1,:),'MM'));
       Dind=find(strcmp(ts(1,:),'DD'));Hind=find(strcmp(ts(1,:),'hh'));
       mInd=find(strcmp(ts(1,:),'mm'));
       if isempty(mInd)==0
           t = vertcat(t, datetime(ts{2,Yind},ts{2,Mind},ts{2,Dind},ts{2,Hind},ts{2,mInd},zeros(size(ts{2,1}))));
       else
           t = vertcat(t, datetime(ts{2,Yind},ts{2,Mind},ts{2,Dind},ts{2,Hind},zeros(size(ts{2,1})),zeros(size(ts{2,1}))));
       end
       buoystruct.time=t;
       fnames = fields(buoystruct); % getting a cell array of our field names
      for j = 2:length(fnames)
          ind=find(strcmp(ts(1,:),fnames{j}));
          bd = buoystruct.(fnames{j}).data;
          bd=vertcat(bd, ts{2,ind});
          buoystruct.(fnames{j}).data = bd; clear bd;
       end
    end
end
%-------------------------------------------------------------------------
% Replacing bad data flags with NaN values
%-------------------------------------------------------------------------
for j = 2:length(fnames)
    bd=buoystruct.(fnames{j}).data;
    bdflag=max(bd); % NDBC Bad data flags are always 9s for as many digits
                    % as are used in that data field and therefore are
                    % always the maximum possible value
    flagcheck = num2str(bdflag);
    flagbool=0;
    for i = 1:numel(flagcheck)
        if str2num(flagcheck(i))~=9
            % The highest value isn't a bad data flag, so no NaNs necessary
            flagbool=1;
        end
    end
    if flagbool==1
        continue
    else
        bd(bd==bdflag)=NaN;
    end
    buoystruct.(fnames{j}).data=bd;
end
%--------------------------------------------------------------------------
% REMOVING INVALID DATA FIELDS
%--------------------------------------------------------------------------
% In an effort to make the lives of researhers easier, NDBC puts out .txt
% files that have the same data fields, even if the buoy does not have the
% instruments to measure those parameters.  These fields will be full of
% bad data flags and thanks to the snippet above, our structure fields will
% be entirely NaNs.  Let's just remove these now so we don't have to bother
% with them.

for j=2:length(fnames)
   if length(buoystruct.(fnames{j}).data) == sum(isnan(buoystruct.(fnames{j}).data))
       buoystruct = rmfield(buoystruct,fnames{j});
   end
end
%--------------------------------------------------------------------------
% Letting the user know what data was not available
%--------------------------------------------------------------------------
if isempty(NoDataYears)==0
    disp('No Data available for the following years:')
    disp(NoDataYears)
end
if isempty(NoDataMonths)==0
    disp('No data available for the following months:')
    disp(NoDataMonths)
end
end

