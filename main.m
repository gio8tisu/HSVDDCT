im = read_lumfile('camman.lum'); %IMAGEN CUADRADA
N = 8; %TAMAÑO BLOQUES
%añadirmos zeros si hace falta
sobran1 = mod(size(im,1),N);
if sobran1
    sobran2 = mod(size(im,2),N);
    if sobran2
        %TODO
    end
end

%para cada bloque de NxN...
for k=1:length(im)/N
    bloque = im(k,k+N);
end