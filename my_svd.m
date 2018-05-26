function [U_l, c, U_r] = my_svd(X, beta)
%SVD TRANSFORM compute singular value descomposition as described in 
% Adriana Dapena and Stanley Ahalt paper
%   The eigenvalues of the R_x=X'X matrix are calculated and then the 
%   number of eigenvectors that must be computed is determined as the
%   smallest value that satisfies the expression (8). Finally transform
%   matrices are computed
    R_x = X'*X;
    l = eig(R_x);
    l = sort(l,'descend');
    %find number p of eigenvectors to compute (based on parameter beta)
    for p=1:length(l)
        if sum(l(1:p))>=beta*sum(l)
            break
        end
    end
    %compute eigenvectors and form U_r U_l matrices
    U_r = zeros(size(R_x,1),p);
    U_l = zeros(size(X,1),p);
    c = sqrt(l(1:p));
    for j=1:p
        u_r = null(R_x-l(j)*eye(size(R_x))); %find solution for (A-lambda*I)u_r=0
        U_r(:,j) = u_r;
        U_l(:,j) = (X*u_r)./c(j);
    end
end

