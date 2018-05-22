im = read_lumfile('Still_images/camman.lum'); %IMAGEN CUADRADA
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
for k=0:N:(length(im)-1)
    bloque = im(1+k:k+N,1+k:k+N);
end