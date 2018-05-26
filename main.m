%% Leer imagen y definir parametros
im = read_lumfile('Still_images/people.lum'); %IMAGEN CUADRADA
im = im/255; %normalizamos
N = 4; %TAMAÑO BLOQUES
Nc = 8; %COEFICIENTES A ENVIAR
alpha = 0.2; %UMBRAL DE DECISIÓN
beta = 0.5; %PARAMETRO PARA NUMERO DE AUTOVECTORES
B = 6; %BITS CUANTIFICADOR COEFICIENTES DCT

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
im_rec = zeros(size(im));
for k=0:N:(size(im,1)-1)
    for l=0:N:(size(im,2)-1)
        bloque = im(1+k:k+N,1+l:l+N);
        desv = std(bloque(:));
        if (desv<alpha)
            B = dct2(bloque);
            coefs = zigzag(B,Nc);
            B_rec = unzigzag(coefs,N);
            bloque_rec = idct2(B_rec);
            im_rec(1+k:k+N,1+l:l+N) = bloque_rec;
        else
            [U_r, c, U_l] = my_svd(bloque, beta);
            bloque_rec = my_svd_inv(U_l, c, U_r);
            im_rec(1+k:k+N,1+l:l+N) = bloque_rec;
        end
    end
end

figure
subplot(2,1,1)
imshow(im',[])
title('Imagen Original')

subplot(2,1,2)
imshow(im_rec',[])
title('Imagen Reconstruida')

diff = im-im_rec;
diff_cuad = diff.^2;
MSE = sum(diff_cuad(:))
PSNR = 10*log(1/MSE)