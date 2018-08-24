# dBFA2Matlab
Representa los datos de historia temporal obtenidos con dBFA y calcula la teoría revisada corregida.

### Uso

En dBFA seleccionar las medidas y en la herramienta de calculo seleccionar `Ecograma` y procesar. Una vez obtenidos los ecogramas seleccionarlos y hacer clic en `Archivo->Exportar`, esto generará un archivo .txt que será el que se cargue desde el script de Matlab.

En el script se debe indicar la posición de la fuente y de los receptores, en el mismo orden que se han seleccionado al exportar. Si se va a calcular la teoría revisada corregida se deben incluir los parámetros del recinto y de la fuente.

**Para conocer en profundidad el concepto de la teoría revisada corregida dejo a disposición mi trabajo ubicado en el repositorio de una Universidad de Alicante <a href="https://rua.ua.es/dspace/handle/10045/77578">Leer</a>**

```matlab
% Valor a analizar '0 a Val' (campo útil) y 'Val a infinito' (perjudicial)
t0 = 50; % (ms)
% Tiempo de campo directo (milisegundos)
tDir = 10;
% ¿Calcular teoría revisada?
CalcTeo = true;
% Parámetros teoría revisada
W = 0.0026;     % Potencia acústica de la fuente. W
Q = 1;          % Factor de directividad de la fuente
c = 343.4;      % Velocidad de sonido en el aire. m/s
S = 530;        % Superficie del recinto. m^2
V = 477;        % Volumen del recinto. m^3
alpha = 0.1176; % Coeficiente medio de absorción
Zimp = 413.48;     % Impedancia acústica del aire
%% Distancia Emisor-Receptor
% Posición de la fuente
         %   X       Y       Z
PosFuente = [0.4    0.6     1.3];
%Mallado de receptores.
            %   X       Y       Z
PosReceptor = [ 1       1.6     1.2; % Receptor 1
                3       1.6     1.2; % Receptor 2
                5.75    1.6     1.2; % Receptor 3
                8       1.6     1.2; % Receptor 4
                10.5	1.6     1.2];  % Receptor 5      

```
