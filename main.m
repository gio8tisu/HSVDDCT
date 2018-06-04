%% Leer y definir parametros
im = read_lumfile('Still_images/fruit.lum'); %IMAGEN CUADRADA
N = 8; %TAMAÑO BLOQUES
Nc = 16; %COEFICIENTES A ENVIAR
alpha = 5; %UMBRAL DE DECISIÓN TRANSFORMACION
beta = 0.99; %UMBRAL PARA NUMERO DE AUTOVECTORES
b = 10; %BITS CUANTIFICADOR VALORES SINGULARES
paso = 1000/(2^b); %PASO CUANTIFICACION (experimentalmente: 0<=c<=1000)
load Q %TABLA CUANTIFICACION JPEG
Q = zigzag(Q, Nc);
gamma = [0.001, 0.1*ones(1,N-1)]; %UMBRALES DISTANCIA
delta = 32; %TAMAÑO CODEBOOKS
E = zeros(N,delta);
counts = zeros(1,delta);
codebook_cod = cell(1,N);
codebook_cod(1,:) = {{E,counts}}; %CODEBOOK CODER
codebook_dec = cell(1,N);
codebook_dec(1,:) = {{E,counts}}; %CODEBOOK DECODER

%% Codec
%añadirmos zeros si hace falta
sobran1 = mod(size(im,1),N);
if sobran1
    im = [im; zeros(N-sobran1, size(im,2))];
    sobran2 = mod(size(im,2),N);
    if sobran2
        im = [im, zeros(size(im,1),N-sobran2)];
    end
end

n_svd = 0; %numero de bloques que usa SVD
nbits = 0; %cantidad de bits
nerrores = 0;
im_rec = zeros(size(im));
im_rec_svd = zeros(size(im));
%para cada bloque de NxN...
for k=0:N:(size(im,1)-1)
    for l=0:N:(size(im,2)-1)
        X = im(1+k:k+N,1+l:l+N);
        desv = std(X(:));%decision en base a la desviacion
        if (desv<alpha) %DCT
            %CODIFICADOR
            B = dct2(X); %transformamos bloque
            coefs = zigzag(B,Nc); %aplanamos coeficientes
            c = round(coefs./Q); %cuantificamos coeficientes
            %DECODIFICADOR
            coefs_q = Q.*double(c); %reconstruimos coeficientes
            B_rec = unzigzag(coefs_q,N); %montamos coeficientes
            X_rec = idct2(B_rec); %reconstruimos bloque
            im_rec(1+k:k+N,1+l:l+N) = X_rec;
            nbits = nbits + Nc*8;
        else %SVD
            n_svd = n_svd + 1;
            %CODIFICADOR
            [U_l, c, U_r] = my_svd(X, beta); %transformamos bloque
            kc = floor(c/paso); %cuantificamos valores singulares
            %Cuantificamos autovectores
            e_l = zeros(size(U_l,2));
            e_r = zeros(size(U_r,2));
            for i=1:size(U_l,2)
                [e_l(i), codebook_cod{i}] = svd_vq(U_l(:,i), ...
                    codebook_cod{i}, gamma(i));
            end
            for i=1:size(U_r,2)
                [e_r(i), codebook_cod{i}] = svd_vq(U_r(:,i), ...
                    codebook_cod{i}, gamma(i));
            end
            %DECODIFICADOR
            c_q = paso*(double(kc)+0.5); %reconstruimos valores singulares
            %reconstruimos autovectores
            U_lq = zeros(N,length(e_l));
            U_rq = zeros(N,length(e_r));
            for i=1:length(e_l)
                if e_l(i)==0
                    [U_lq(:,i), codebook_dec{i}] = isvd_vq(e_l(i),...
                        codebook_dec{i}, U_l(:,i));
                    nbits = nbits + N*32; %bits del vector double
                else
                    [U_lq(:,i), codebook_dec{i}] = isvd_vq(e_l(i),...
                        codebook_dec{i});
                    nbits = nbits + 5; %bits del indice
                end
                nbits = nbits + 1; %bit de flag fl
            end
            for i=1:length(e_r)
                if e_r(i)==0
                    [U_rq(:,i), codebook_dec{i}] = isvd_vq(e_r(i),...
                        codebook_dec{i}, U_r(:,i));
                    nbits = nbits + N*32; %bits del vector double
                else
                    [U_rq(:,i), codebook_dec{i}] = isvd_vq(e_r(i),...
                        codebook_dec{i});
                    nbits = nbits + 5; %bits del indice
                end
                nbits = nbits + 1; %bit de flag fr
            end
            X_rec = my_svd_inv(U_lq, c_q, U_rq); %reconstruimos bloque
            im_rec(1+k:k+N,1+l:l+N) = X_rec;
            nbits = nbits + b*length(c); %bits valores singulares
        end
        nbits = nbits + 1; %bit de flag fa
    end
end


%% resultado
figure
subplot(1,2,1)
imshow(im',[0 255])
title('Imagen Original')

subplot(1,2,2)
imshow(im_rec',[0 255])
title('Imagen Reconstruida')

diff = im-im_rec;
diff_cuad = diff.*diff;
MSE = sum(diff_cuad(:))/numel(im)
PSNR = 10*log(255^2/MSE)

bpp = nbits/(numel(im)-nerrores*16)

n_svd

fprintf('(%1.3f,%2.2f)\n',bpp,PSNR)