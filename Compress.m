1;

function small_img = compress(originalImg, k)
  [x,y,z] = size(originalImg);
  n = (x+k)/(k+1);
  m = (y+k)/(k+1);
  if(0==mod(x+k, k+1) & 0==mod(y+k,k+1))
    novam = zeros(n,m,z);
    for h=1:z
        for i=1:n
            for j=1:m
                      novam(i, j, h) = originalImg(1+(i-1)*(k+1), 1+(j-1)*(k+1), h); 
            endfor
        endfor
    endfor
    small_img=novam;
    imwrite(uint8(novam), "compressed.png"); 
  else
    small_img=[0];
    display("Não foi possível comprimir a imagem. Digite outro valor para k.");
  endif
endfunction

A=imread('sen.png');

final_img = compress(A,2);
display(final_img);
   