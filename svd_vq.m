function [e, codebook] = svd_vq(u, codebook, gamma)
%EIGENVECTOR QUANTIZATION Quantize as described in paper
%   Find closest vector in codebook. If its close enough return index,
%   return 0 otherwise.
    E = codebook{1};
    counts = codebook{2};
    dist = (E(:,1)-u)'*(E(:,1)-u); %distancia del autovector a palabra codigo
    e = 1; %indice de vector con menor distancia
    %buscamos la menor distancia
    for j=2:size(E,2)
        aux = (E(:,j)-u)'*(E(:,j)-u);
        if aux<dist
            dist = aux;
            e = j;
        end
    end
    if dist<=gamma
        %actualizamos contador 
        counts(e) = counts(e) + 1;
    else
        %sustituimos la palabra codigo menos frecuente por la de menor
        %distancia
        e = 0;
        [~,lfu] = min(counts);
        E(:,lfu) = single(u); %cuantificamos con 32 bits
        counts(lfu) = 1;
        codebook{1} = E;
    end
    codebook{2} = counts;
end

