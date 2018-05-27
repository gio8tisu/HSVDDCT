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
        E(:,lfu) = u;
        counts(lfu) = 1;
        codebook{1} = E;
        u_q = u;
    end
    codebook{2} = counts;
end

