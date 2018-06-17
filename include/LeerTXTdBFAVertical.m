function [ID,Res,Pos,Medidas,Comment] = LeerTXTdBFAVertical(TXT)

% Primero crea una copia temporal del txt cambiando las comas por puntos
arreglar(TXT);

% Extraer los datos brutos
datos = extraer(strcat(TXT,'_temp'));
% Elimina el archivo temporal
delete(strcat(TXT,'_temp'));

% Obtener numero de medidas a traves de contar cuantos Id contiene el TXT
IndiceID=find(strcmp(datos, 'Id'));
IndiceFinal=[IndiceID(2:end)-1;size(datos,1)];

% Obtener una lista de la ID de cada medida
ID = str2double(string(datos(IndiceID,2)))';
% Obtener comentarios
Comment = str2double(string(datos(IndiceID+2,2)));
% Obtener distancia entre muestras de cada medida (resolucion)
Res = str2double(string(datos(IndiceID+11,2)))';
% Obtener una lista de  nombres de las posiciones de cada medida
Pos = string(datos(IndiceID+14,2))';
% Obtener los datos de medida
Medidas = cell(size(ID));
for i=1:numel(ID)
Medidas{i} = str2doubleq(datos(IndiceID(i)+27:IndiceFinal(i),2:end));
%Medidas{i}(Medidas{i}==0) = NaN;
Medidas{i} = fillmissing(Medidas{i},'linear','EndValues','extrap');
end

end

function arreglar(TXT)

% Lee el archivo TXT
fid  = fopen(TXT,'r');
% Guarda el contenido en la variable f
f=fread(fid,'*char')';
fclose(fid);
% Reemplaza las comas por puntos
f = strrep(f,',','.');
% Crea el archivo temporal
fid  = fopen(strcat(TXT,'_temp'),'w');
% Guarda el contenido modificado en el archivo temporal
fprintf(fid,'%s',f);
% Cierra el archivo
fclose(fid);

end

function AulaOpticaLlenaEsquina = extraer(filename, startRow, endRow)


%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format for each line of text:
%   column1: text (%s)
%	column2: text (%s)
%   column3: text (%s)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: text (%s)
%   column9: text (%s)
%	column10: text (%s)
%   column11: text (%s)
%	column12: text (%s)
%   column13: text (%s)
%	column14: text (%s)
%   column15: text (%s)
%	column16: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
AulaOpticaLlenaEsquina = [dataArray{1:end-1}];
end