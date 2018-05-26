function [B] = unzigzag(coeffs, N)
%UNZIGZAG creates NxN matrix filled with coeffs in a zigzag order
%   Detailed explanation goes here
    B=zeros(N);
    cursor = [1 1];
    cont = 1;
    coeffs = [coeffs;zeros(N*N-size(coeffs,1),1)]
    while cont<=(N*N)
        if cursor(2)==1 && cursor(1)<size(B,1) || cursor(2)==size(B,2)
            B(cursor(1),cursor(2)) = coeffs(cont);
            cursor(1) = cursor(1) + 1;
            cont = cont + 1;
        elseif cursor(1)==1 && cursor(2)<size(B,2) || cursor(1)==size(B,1)
            B(cursor(1),cursor(2)) = coeffs(cont);
            cursor(2) = cursor(2) + 1;
            cont = cont + 1;
        end
        if cursor(2)==1 || cursor(1)==size(B,2)
            while cursor(1)~=1 && cursor(2)~=size(B,2) && cont<=(N*N)
                %subir en diagonal
                B(cursor(1),cursor(2)) = coeffs(cont);
                cursor(2) = cursor(2) + 1;
                cursor(1) = cursor(1) - 1;
                cont = cont + 1;
            end
        elseif cursor(1)==1 || cursor(2)==size(B,1)
            while cursor(2)~=1 && cursor(1)~=size(B,1) && cont<=(N*N)
                %bajar en diagonal
                B(cursor(1),cursor(2)) = coeffs(cont);
                cursor(1) = cursor(1) + 1;
                cursor(2) = cursor(2) - 1;
                cont = cont + 1;
            end
        end  
    end
end

