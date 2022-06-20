#iniciar as variaveis como default
x=y=z=M=k=h=0;
#M: matriz decompress, (x,y) coordenadas
function resultado = derivate_fx(x,y,z,M,k,h)
  [a,b,c] = size(M);
  if(x==1)
    resultado = (M(x,y,z)-M(x+k+1,y,z))/(h);
  elseif(x==a)
    resultado = (M(x-k-1,y,z)-M(x,y,z))/(h);
  else
    resultado = (M(x-k-1,y,z)-M(x+k+1,y,z))/(2*h);
  endif
endfunction

function resultado = derivate_fy(x,y,z,M,k,h)
  [a,b,c]=size(M);
  if(y==1)
    resultado = (M(x,y+k+1,z)-M(x,y,z))/(h);
  elseif(y==b)
    resultado = (M(x,y,z)-M(x,y-k-1,z))/(h);
  else
    resultado = (M(x,y+k+1,z)-M(x,y-k-1,z))/(2*h);
  endif
endfunction

function resposta = Pij(A,x,xi,y,yj)
    a = x-xi;
    PX = [1, a, a**2, a**3];
    b= y-yj;
    PY = [1;
         b;
         b**2;
         b**3];
    resposta = PX * A * PY;
endfunction

#nao sei se vai dar certo, testar
function resultado = derivate_fxy(x,y,z,M,k,h)
  
    a = derivate_fx(x,y,z,M,k,h);
    b = derivate_fy(x,y,z,M,k,h);
  
  resultado = (a-b)/(2*h);
endfunction


A=x=xi=y=yi=0;
function resposta = Pij_bilinear(A,x,xi,y,yj)
    a0=A(1);
    a1=A(2);
    a2=A(3);
    a3=A(4);
    
    dx = x-xi; #diferenca de x
    dy = y-yj; #diferenca de y
    um = a1*dx;
    dois = a2*dy;
    tres = a3*dx*dy;
    resposta = a0+um+dois+tres;
endfunction

#RESOLVER O UNDEFINED A PARTIR DAQUI
function  finalImg = decompress(compressedImg, method, k, h)
    [a, b, c]=size(compressedImg);

    aq = zeros(a + (a-1)*k, b + (b-1)*k, c);
    
    #cria a imagem decompressed
    for h=1:c
        for i=1:a
            for j=1:b
                      aq(1+(i-1)*(k+1), 1+(j-1)*(k+1), h) = compressedImg(i,j,h);
            endfor
        endfor
    endfor
    
    M = aq;
    [nrow,ncol,nz]=size(M);
    #bilinear
    if(method == 1)
      #(xi,yi)      (xi,yi_p1)
      #
      #(xi_p1,yi)      (xi_p1,yi_p1)
      #procura um quadrado (pequeno) para ser preenchido
      i = 1; #linha
      j = 1; #coluna
      
      #para encontrar os coeficientes da matriz é preciso resolver uma equaçaõ de multiplicação de matrizes
      B = [1, 0, 0, 0;
           1, 0, h, 0;
           1, h, 0, 0;
           1, h, h, h**2];
      #B invertido
      B_inv = inv(B);
      
      
      for t=1:nz
        #percorre as linhas da matriz descompress e vai completando-a
        while (i<nrow)
          #percorre as colunas
          while(j<ncol)
            xi=i;
            xi_p1=i+k+1;
            yj=j;
            yj_p1=j+k+1;
            
            F = [M(xi,yj,t);
                 M(xi,yj_p1,t);
                 M(xi_p1,yj,t);
                 M(xi_p1,yj_p1,t)];
           
            #fazendo as contas da equação: B_inv * F = A
            #A: matriz das incognitas
            A = B_inv * F;
            
            #completa o quadrado pequeno
            for ii=i:i+k+1
              for jj=j:j+k+1
                if(M(ii,jj,t)==0)
                  M(ii,jj,t) = Pij_bilinear(A,ii,xi,jj,yj);
                endif
              endfor
            endfor          
            j=j+k+1; #depois de preenchido, passa para o quadrado à direita
          endwhile
          j=1;
          i=i+k+1;
        endwhile
        i=1;
        j=1;
      endfor
    
    #bicubica
    elseif(method == 2)  
      #display(aq);
      
      #(xi,yi)      (xi,yi_p1)
      #
      #(xi_p1,yi)      (xi_p1,yi_p1)
      #procura um quadrado (pequeno) para ser preenchido
      i = 1; #linha
      j = 1; #coluna
      
      #para encontrar os coeficientes da matriz é preciso resolver uma equaçaõ de multiplicação de matrizes
      B = [1, 0, 0, 0;
           1, h, h**2, h**3;
           0, 1, 0, 0;
           0, 1, 2*h, 3*(h**2)];
      #B transposta
      B_t = transpose(B);
      #matrizes invertidas
      B_inv = inv(B);
      B_t_inv = inv(B_t);
      for t=1:nz
        #percorre as linhas da matriz descompress e vai completando-a
        while (i<nrow)
          #percorre as colunas
          while(j<ncol)
            xi=i;
            xi_p1=i+k+1;
            yj=j;
            yj_p1=j+k+1;
            
            f1 = aq(xi,yj,t);
            f2 = aq(xi,yj_p1,t);
            f5 = aq(xi_p1,yj,t);
            f6 = aq(xi_p1,yj_p1,t);
            
            
              f3 = derivate_fy(xi,yj,t,M,k,h);
              f7 = derivate_fy(xi_p1,yj,t,M,k,h);
            

            
              f4 = derivate_fy(xi,yj_p1,t,M,k,h);
              f8 = derivate_fy(xi_p1,yj_p1,t,M,k,h);
            

            
              f9 = derivate_fx(xi,yj,t,M,k,h);
              f10 = derivate_fx(xi,yj_p1,t,M,k,h);
            
            
            
            f13 = derivate_fx(xi_p1,yj,t,M,k,h);
            f14 = derivate_fx(xi_p1,yj_p1,t,M,k,h);
            
            f11 = derivate_fxy(xi,yj,t,M,k,h);
            f12 = derivate_fxy(xi,yj_p1,t,M,k,h);
            f15 = derivate_fxy(xi_p1,yj,t,M,k,h);
            f16 = derivate_fxy(xi_p1,yj_p1,t,M,k,h);
            
            F=[f1,f2,f3,f4;
               f5,f6,f7,f8;
               f9,f10,f11,f12;
               f13,f14,f15,f16];
            
            #fazendo as contas da equação: B_inv * F * B_t_inv = A
            #A: matriz das incognitas
            A = B_inv * F * B_t_inv;
            
            #completa o quadrado pequeno
            for ii=i:i+k+1
              for jj=j:j+k+1
                if(M(ii,jj,t)==0)
                  M(ii,jj,t) = Pij(A,ii,xi,jj,yj);
                endif
              endfor
            endfor          
            j=j+k+1; #depois de preenchido, passa para o quadrado à direita
          endwhile
          j=1;
          i=i+k+1;
        endwhile
        i=1;
        j=1;
      endfor
    else 
      M=0;
      display("Digite um método válido");
    endif
    
    
    finalImg = M;
    imwrite(uint8(M), "decompressed2.png"); 
    
endfunction
   
C=imread('compressed.png');
   
decompress(C, 2, 2, 1);



