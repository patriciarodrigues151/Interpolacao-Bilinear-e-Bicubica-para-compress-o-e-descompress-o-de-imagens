1;
function calculateError(originalImg, decompressedImg) 
  origR = double(originalImg(:, :, 1));  #vermelho da originalImg
  origG = double(originalImg(:, :, 2));  #verde da originalImg
  origB = double(originalImg(:, :, 3));  #azul da originalImg
  decR = double(decompressedImg(:, :, 1)); #vermelho da decompressedImg
  decG = double(decompressedImg(:, :, 2)); #verde da decompressedImg
  decB = double(decompressedImg(:, :, 3)); #azul da decompressedImg
 
  #calculo dos erros
  errR = (norm(origR-decR))/(norm(origR)); #vermelho
  errG = (norm(origG-decG))/(norm(origG)); #verde
  errB = (norm(origB-decB))/(norm(origB)); #azul
   
  display((errR + errG + errB)/3); 
endfunction

A=imread('sen.png');

B=imread('decompressed2.png');

calculateError(A,B);
