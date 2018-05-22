function [I] = read_lumfile(name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fID = fopen(name);
    I = fread(fID);
    fclose(fID);
    I = reshape(I,sqrt(length(I))*ones(1,2));
end

