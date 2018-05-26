function [coeffs] = zigzag(B, n_c)
%ZIGZAG flattens matrix in a zigzag order
%   Detailed explanation goes here
    coeffs = zeros(n_c,1);
    cursor = [1 1];
    cont = 1;
    while cont<=n_c
        %bajar una posicion
        if cursor(2)==1 && cursor(1)<size(B,1) || cursor(2)==size(B,2)
            coeffs(cont) = B(cursor(1),cursor(2));
            cursor(1) = cursor(1) + 1;
            cont = cont + 1;
        %mover derecha una posicion
        elseif cursor(1)==1 && cursor(2)<size(B,2) || cursor(1)==size(B,1)
            coeffs(cont) = B(cursor(1),cursor(2));
            cursor(2) = cursor(2) + 1;
            cont = cont + 1;
        end
        if cursor(2)==1 || cursor(1)==size(B,2)
            while cursor(1)~=1 && cursor(2)~=size(B,2) && cont<=n_c
                %subir en diagonal
                coeffs(cont) = B(cursor(1),cursor(2));
                cursor(2) = cursor(2) + 1;
                cursor(1) = cursor(1) - 1;
                cont = cont + 1;
            end
        elseif cursor(1)==1 || cursor(2)==size(B,1)
            while cursor(2)~=1 && cursor(1)~=size(B,1) && cont<=n_c
                %bajar en diagonal
                coeffs(cont) = B(cursor(1),cursor(2));
                cursor(1) = cursor(1) + 1;
                cursor(2) = cursor(2) - 1;
                cont = cont + 1;
            end
        end  
    end
end

