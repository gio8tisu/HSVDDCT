function [u_q,codebook] = isvd_vq(e, codebook, u)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    E = codebook{1};
    counts = codebook{2};
    if e~=0
        %cogemos palabra codigo y actualizamos contador
        u_q = E(:,e);
        counts(e) = counts(e) + 1;
    else
        %sustituimos la palabra de menor frecuencia por la nueva
        [~,lfu] = min(counts);
        E(:,lfu) = single(u);
        counts(lfu) = 1;
        codebook{1} = E;
        u_q = single(u); %cuantificamos con 32 bits
    end
    codebook{2} = counts;
end

