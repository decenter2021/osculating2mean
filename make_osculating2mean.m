% Very crude way of storing data path 
fid1 = fopen('./KaulaGeopotentialPerturbations_mex.F');
fid2 = fopen('tmp.F','w');
while 1
    tline = fgetl(fid1);
    if ~ischar(tline), break, end % EOF 
    if ~(length(tline)>= 17 && strcmp(tline(1:17),'c begin data path'))
        fprintf(fid2,"%s\n",tline);   
    else
        aux = sprintf('%s/data/egm96_degree360.ascii',pwd);
        fprintf(fid2,"c begin data path\n"); 
        fprintf(fid2, "      ifile1 = '%s'", aux(1:min(40,length(aux))));
        idxChar = min(40,length(aux));
        while idxChar < length(aux)
            fprintf(fid2, "//\n     1 '%s'", aux(idxChar+1:min(idxChar+40,length(aux))));
            idxChar = min(idxChar+40,length(aux));
        end
        fprintf(fid2,"\n"); 
        fprintf(fid2,"c end data path\n");
        while 1
            tline = fgetl(fid1);
            if length(tline)>= 15 && strcmp(tline(1:15),'c end data path')
                break;
            end
        end
    end    
end
fclose(fid1);
fclose(fid2);
movefile('./tmp.F','./KaulaGeopotentialPerturbations_mex.F');
% Compile
mex -setup fortran
mex KaulaGeopotentialPerturbations_mex.F