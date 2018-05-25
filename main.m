im = read_lumfile('Still_images/camman.lum'); %IMAGEN CUADRADA
im = im/255; %normalizamos
N = 4; %TAMAÑO BLOQUES
Nc = %COEFICIENTES A ENVIAR
alpha = 0.5; %UMBRAL DE DECISIÓN
beta = 0.5; %PARAMETRO PARA NUMERO DE AUTOVECTORES
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
    desv = std(bloque(:));
    if (desv<alpha)
        B = dct2(bloque);
        coefs = zigzag(B,Nc);
    else
        [Ur, X, Ul] = svd(bloque);
    end    
end
