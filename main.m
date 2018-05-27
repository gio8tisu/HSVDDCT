%% Leer y definir parametros
im = read_lumfile('Still_images/diff.lum'); %IMAGEN CUADRADA
N = 4; %TAMAÑO BLOQUES
Nc = 8; %COEFICIENTES A ENVIAR
alpha = 20; %UMBRAL DE DECISIÓN TRANSFORMACION
beta = 0.8; %UMBRAL PARA NUMERO DE AUTOVECTORES
B = 8; %BITS CUANTIFICADOR VALORES SINGULARES
paso = 1000/(2^B); %PASO CUANTIFICACION ( 0<=c<=1000)
load Q %TABLA CUANTIFICACION JPEG
Q = zigzag(Q, Nc);
gamma = [0.001, 0.1*ones(1,N-1)]; %UMBRALES DISTANCIA
delta = 32; %TAMAÑO CODEBOOKS
E = zeros(N,delta);
counts = zeros(1,delta);
codebook_cod = cell(1,N);
codebook_cod(1,:) = {{E,counts}};
codebook_decod = cell(1,N);
codebook_decod(1,:) = {{E,counts}};

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

%para cada bloque de NxN...
nbits = 0; %cantidad de bits
nerrores = 0;
im_rec = zeros(size(im));
im_rec_svd = zeros(size(im));
for k=0:N:(size(im,1)-1)
    for l=0:N:(size(im,2)-1)
        X = im(1+k:k+N,1+l:l+N);
        desv = std(X(:));%decision en base a la desviacion
        if (desv<alpha) %DCT
            %CODIFICADOR
            B = dct2(X); %transformamos bloque
            coefs = zigzag(B,Nc); %aplanamos coeficientes
            c = int8(round(coefs./Q)); %cuantificamos coeficientes
            %DECODIFICADOR
            coefs_q = Q.*double(c); %reconstruimos coeficientes
            B_rec = unzigzag(coefs_q,N); %montamos coeficientes
            X_rec = idct2(B_rec); %reconstruimos bloque
            im_rec(1+k:k+N,1+l:l+N) = X_rec;
            nbits = nbits + Nc*8;
        else %SVD
            try
                %CODIFICADOR
                [U_l, c, U_r] = my_svd(X, beta); %transformamos bloque
                kc = uint(floor(c/paso)); %cuantificamos valores singulares
                %Cuantificamos de autovectores
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
                U_lq = zeros(size(R_x,1),length(e_l));
                U_rq = zeros(N,length(e_r));
                for i=1:length(e_l)
                    if e_l(i)==0
                        [U_lq(:,i), codebook_decod{i}] = isvd_vq(e_l(i),...
                            codebook_decod{i}, U_l(:,i));
                        nbits = nbits + size(R_x,1)*64; %bits del vector double
                    else
                        [U_lq(:,i), codebook_decod{i}] = isvd_vq(e_l(i),...
                            codebook_decod{i});
                        nbits = nbits + 5; %bits del indice
                    end
                    nbits = nbits + 1; %bit de flag fl
                end
                for i=1:length(e_r)
                    if e_r(i)==0
                        [U_rq(:,i), codebook_decod{i}] = isvd_vq(e_r(i),...
                            codebook_decod{i}, U_r(:,i));
                        nbits = nbits + N*64; %bits del vector double
                    else
                        [U_rq(:,i), codebook_decod{i}] = isvd_vq(e_r(i),...
                            codebook_decod{i});
                        nbits = nbits + 5; %bits del indice
                    end
                    nbits = nbits + 1; %bit de flag fr
                end
                X_rec = my_svd_inv(U_lq, c_q, U_rq); %reconstruimos bloque
                im_rec(1+k:k+N,1+l:l+N) = X_rec;
                nbits = nbits + B*length(c);
            catch ME
                warning(ME.identifier, '%s in block %d,%d', ME.message, k, l)
                im_rec(1+k:k+N,1+l:l+N) = X;
                nerrores = nerrores + 1;
            end
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
MSE = sum(diff_cuad(:))
PSNR = 10*log(255/MSE)

bpp = nbits/numel(im)