function [X_rec] = my_svd_inv(U_l, c, U_r)
%INVERSE SVD TRANSFORM reconstruct matrix X from p matrices and
%singular values
%   Detailed explanation goes here
    X_rec = zeros(size(U_l,1),size(U_r,1));
    for i=1:length(c)
        X_rec = X_rec + c(i).*U_l(:,i)*U_r(:,i)';
    end
end

