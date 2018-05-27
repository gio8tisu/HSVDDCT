function [e] = svd_vq(u, E, gamma)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    dist = (E(:,1)-u)'*(E(:,1)-u);
    e = 1;
    for j=2:size(E,2)
        aux = (E(:,j)-u)'*(E(:,j)-u);
        if aux<dist
            dist = aux;
            e = j;
        end
    end
    if dist>gamma
        e = 0;
    end
end

