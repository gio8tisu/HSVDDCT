%% Leer imagen y definir parametros
im = read_lumfile('Still_images/camman.lum'); %IMAGEN CUADRADA
im = im/255; %normalizamos
N = 4; %TAMAÑO BLOQUES
Nc = 12; %COEFICIENTES A ENVIAR
alpha = 0.2; %UMBRAL DE DECISIÓN
beta = 0.8; %PARAMETRO PARA NUMERO DE AUTOVECTORES

%% Codificador
%añadirmos zeros si hace falta
sobran1 = mod(size(im,1),N);
if sobran1
    im = [im; zeros(N-sobran1, size(im,2))];
    sobran2 = mod(size(im,2),N);
    if sobran2
        im = [im, zeros(size(im,1),N-sobran2)];
    end
end

%para cada bloque de NxN...
im_rec = [];
for k=0:N:(length(im)-1)
    bloque = im(1+k:k+N,1+k:k+N);
    desv = std(bloque(:));
    if (desv<alpha)
        B = dct2(bloque);
        coefs = zigzag(B,Nc);
    else
        [U_r, c, U_l] = my_svd(bloque, beta);
        bloque_rec = my_svd_inv(U_l, c, U_r);
        im_rec = [im_rec; bloque_rec];
    end    
end
