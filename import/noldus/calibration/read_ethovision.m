function [ data ] = read_ethovision( fn )
%READ_ETHOVISION Loads native Ethovision format file into cell array
% for later post_processing by read_trajectory
% Input csv files have variable sized headers and variable number of column
% widths
% Author: Mike Croucher

%Determine properties of input file
fileID = fopen(fn);
%Skip through header
%The last header line always begins with 'Sample no.'
header_line = fgetl(fileID);
while ~strncmp(header_line,'Sample no.',10) && ischar(header_line) 
  header_line = fgetl(fileID);
end

%If no 'Sample no.' string was found, there is something wrong with the
%input file
if ~ischar(header_line)
    error('read_ethovision:InvalidFileFormat',['The input file ',fn,' is invalid']);
end
%The next line of data contains the columns we are attempting to count
data_line = fgetl(fileID);
fclose(fileID);

%How many columns in this data_line?
data_line = textscan(data_line,'%s','Delimiter',',');
num_cols = length(data_line{1});

%Create a format specifier of the correct size
fmt = repmat('%s ',[1,num_cols]);

%Read data
fileID = fopen(fn);
data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
data=data{1};
fclose(fileID);


end

