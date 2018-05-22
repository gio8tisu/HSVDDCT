function [coeffs] = zigzag(dct_c, n_c)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    coeffs = zeros(n_c,1);
    cursor = [1 1];
    coeffs(1) = dct_c(cursor(1),cursor(2));
end

