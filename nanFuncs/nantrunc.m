function [data] = nantrunc(data,dataindex,truncindex)
%NANTRUNC This function reads in a data structure or vector and truncates
%it using the truncindex provided.  It is intended to work with the other
%NaN interpolation functions I have been using.
% C. Ryan Manzer, Moss Landing Marine Labs - 7/16/2015
%   INPUTS
%       data - either a structure or a vector that requires truncating.  If
%       it represents a structure then all fieldnames will be looped
%       through and truncated.  The dataindex value will be used in the
%       event the structure is larger than 1x1
%       dataindex - In the event we have a multi-part structure, this index
%       is used to determine which sections should be truncated.
%       truncindex - this index is used to find the specific indeces to be
%       truncated.  If data is a multi-part structure dataindex is used to
%       further identify which vectors will be truncated.  All field names
%       will be interated through and the truncindex will be applied.

if isstruct(data)==0 % if our data is a vector rather than a structure
    data(truncindex)=[]; % we simply truncate that vector, easy!
else
    fnames = fieldnames(data);
    for i = 1:length(fnames)
        if dataindex > 0
            for k = 1:length(truncindex)
                if isstruct(data(dataindex).(fnames{i}))==1
                    cfnames=fieldnames(data(dataindex).(fnames{i}));
                    for j = 1:length(cfnames)
                        data(dataindex).(fnames{i}).(cfnames{j})(truncindex{k})=[];
                    end
                else
                    data(dataindex).(fnames{i})(truncindex{k})=[];
                end
            end
        else
            for k = 1:length(tuncindex)
                data.(fnames{i})(truncindex{k})=[];
            end
        end
    end
end
end

