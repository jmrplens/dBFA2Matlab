clear; clc; close all;
addpath('include')
% Archivo a importar
TXT='Demo-48receptores.txt';

% Valor a analizar '0 a Val' (campo util) y 'Val a infinito' (perjudicial)
t0 = 50; % (ms)

% Tiempo de campo directo (milisegundos)
tDir = 10;

% Calcular teoria revisada?
CalcTeo = true;
% Parametros teoria revisada
W = 0.0026;     % Potencia acustica de la fuente. W
Q = 1;          % Factor de directividad de la fuente
c = 343.4;      % Velocidad de sonido en el aire. m/s
S = 530;        % Superficie del recinto. m^2
V = 477;        % Volumen del recinto. m^3
alpha = 0.1176; % Coeficiente medio de absorcion
Zimp = 413.48;     % Impedancia acústica del aire

%% Distancia Emisor-Receptor
% Posicion de la fuente
         %   X       Y       Z
PosFuente = [0.4    0.6     1.3];
% Posicion de cada receptor en el mismo orden que en el que se encuentran
% en el TXT

% Mallado de receptores. Tambien se puede hacer una matriz con columnas
% X,Y,Z para la posicion de cada receptor, ejemplo:
%                         %   X       Y       Z
%             PosReceptor = [ 1       1.6     1.2;
%                             3       1.6     1.2;
%                             5.75    1.6     1.2;
%                             8       1.6     1.2;
%                             10.5	  1.6     1.2];
    
X = repmat([0.9:1:16]',3,1);
Y = [ones(16,1)*1.4;ones(16,1)*5.4;ones(16,1)*7.6];
Z = ones(48,1)*1.2;

PosReceptor = [X,Y,Z];

% Calculo de la distancia Fuente-Receptor    
for d=1:length(PosReceptor)
        Distancia(d) = sqrt(...
            (PosReceptor(d,1)-PosFuente(1))^2+...
            (PosReceptor(d,2)-PosFuente(2))^2+...
            (PosReceptor(d,3)-PosFuente(3))^2);
end

%% Obtiene los datos del archivo TXT
% ID - Devuelve un vector con la ID de cada medida
% Res - Devuelve un vector con la resolucion temporal
% Pos - Devuelve un vector de string con el nombre de cada posicion
% Comment - Devuelve un vector de string con el contenido de la columna
% comment
% Medidas - Devuelve una matriz con los valores de cada medida por columnas
[ID,Res,Pos,Medidas,Comment]=LeerTXTdBFAVertical(TXT);

% Separar datos temporalmente
for i=1:numel(ID)
    MedidasDirecto{i}  = Medidas{i}(1:tDir,:);
    MedidasTemprano{i}   = Medidas{i}(tDir+1:t0,:);
    MedidasPerjudicial{i} = Medidas{i}(t0+1:end,:);
end

% Vector de distancias para las curvas
Distplot = min(Distancia):0.01:max(Distancia); 

%% Suma de niveles
% Suma (Para obtener valor de 0 a rango y de rango a infinito por bandas)
% Primero se pasa a lineal, y despues se suma
SumDirecto = cellfun( @(lin) sum(10.^(lin/10)), MedidasDirecto,'UniformOutput',0);
SumTemprano = cellfun( @(lin) sum(10.^(lin/10)), MedidasTemprano,'UniformOutput',0);
SumPerjudicial = cellfun( @(lin) sum(10.^(lin/10)), MedidasPerjudicial,'UniformOutput',0);

% Conversion a dB
SumDirecto = 10*log10(cell2mat(SumDirecto'));
SumTemprano = 10*log10(cell2mat(SumTemprano'));
SumPerjudicial = 10*log10(cell2mat(SumPerjudicial'));

% Suma de los niveles por octava para obtener un nivel para cada receptor
SumSumDirecto=10*log10(sum(10.^(SumDirecto/10),2));
SumSumTemprano=10*log10(sum(10.^(SumTemprano/10),2));
SumSumPerjudicial=10*log10(sum(10.^(SumPerjudicial/10),2));

% Campo Directo
Dneto = SumSumDirecto;
% Campo Temprano
Eneto = SumSumTemprano;
% Campo util (suma directo y temprano)
Uneto = 10*log10(10.^(SumSumDirecto/10)+10.^(SumSumTemprano/10));
% Campo perjudicial
Pneto = SumSumPerjudicial;

%% Distancias-Niveles
% Concatena distancias y niveles y reordena segun distancia de menor a mayor
Dist_U = sortrows([Distancia',Uneto]);
Dist_P = sortrows([Distancia',Pneto]);

% Si tiene distancias duplicadas se promedia el nivel de las dos distancias
% iguales y elimina el duplicado
% 0 a rango
[C,~,idx] = unique(Dist_U(:,1),'stable');
val = accumarray(idx,Dist_U(:,2),[],@mean);
Dist_U = [C,val];
% Rango a infinito
[C,~,idx] = unique(Dist_P(:,1),'stable');
val = accumarray(idx,Dist_P(:,2),[],@mean);
Dist_P = [C,val];

%% Representacion grafica
f = figure('units','normalized','Color',[1,1,1],'position',[0.25 1 0.5 0.5]);
colores = colormap(jet(21));
% Indices de color
iCU = 1;
iCUt = 3;
iCL = 18;
iCLt = 21;

% 0 a rango
% Vector distancia
Dist = Dist_U(:,1);
Urec = Dist_U(:,2);
% Ajuste a curva
[Ucoef,Ures,Uoutput] = fit(Dist,Urec,'power1');
Uplot = Ucoef.a*Distplot.^Ucoef.b; % Curva
% Muestra los puntos
plot(Dist,Urec,'s','Color',colores(iCU,:),'MarkerFaceColor',colores(iCU,:))
hold on
% Muestra la curva
Curv(1) = plot(Distplot,Uplot,'Color',colores(iCU,:),'LineWidth',1.2);

% rango a infinito
% Vector distancia
Dist = Dist_P(:,1);
Prec=Dist_P(:,2);
% Obtener coeificentes curva polinomica de grado 1
[Pcoef,Pres,Poutput] = fit(Dist,Prec,'poly1');
Pplot = Pcoef.p1*Distplot+Pcoef.p2;% Curva
% Muestra los puntos
plot(Dist,Prec,'^','Color',colores(iCL,:),'MarkerFaceColor',colores(iCL,:))
hold on
% Muestra la curva
Curv(2)=plot(Distplot,Pplot,'Color',colores(iCL,:),'LineWidth',1.2);

% Obtener punto de cruce
CortesInd = find(abs(Uplot-Pplot)<=(0.01));
if ~isnan(CortesInd)
    DistCorte = Distplot(CortesInd(1));
    text(DistCorte,Uplot(CortesInd(1))+1,...
        {strcat('\bf\color{black}',[sprintf('%4.3f',DistCorte),' m'])},...
        'VerticalAlignment','bottom','HorizontalAlignment','left')
    plot(DistCorte,Uplot(CortesInd(1)),...
        'ko','MarkerFaceColor','black','MarkerSize',8)
end

% Ajustes de leyenda
P11 = num2str(fix(abs(log10(abs(Ucoef.b))))+2);
P21 = num2str(fix(abs(log10(abs(Pcoef.p1))))+2);
% Leyenda
leyenda{1} = sprintf(['\\bf0 %s %d ms\\rm   R^2 = %4.2f\n\\color{blue}y = %4.2f·x^{%4.',P11,'f} \n \\color{white}.'],'a',t0,Ures.adjrsquare,Ucoef.a,Ucoef.b);
leyenda{2} = sprintf(['\\bf%d ms %s\\rm   R^2 = %4.2f\n\\color{red}y = %4.',P21,'f·x+%4.2f \n \\color{white}.'],t0,'a infinito',Pres.adjrsquare,Pcoef.p1,Pcoef.p2);


if CalcTeo
    [Pdeplot,Plateplot,Cd,ee,Ce,el,Cl,gofD,gofE,gofL] = ...
        TeoRevCorregida(Dneto,Eneto,Pplot,Distancia,Distplot,W,Q,c,S,V,alpha,Zimp,t0);
    Curv(3) = plot(Distplot,Pdeplot,'-.','Color',colores(iCUt,:),'LineWidth',1);
    Curv(4) = plot(Distplot,Plateplot,'-.','Color',colores(iCLt,:),'LineWidth',1);
    
     % Colores en formato texto para el color de las funciones
    ColUteo = [num2str(colores(iCUt,1)),',',num2str(colores(iCUt,2)),',',num2str(colores(iCUt,3))];
    ColLteo = [num2str(colores(iCLt,1)),',',num2str(colores(iCLt,2)),',',num2str(colores(iCLt,3))];
    
    % Leyendas
    leyenda{3} = sprintf('\\bf0 %s %d ms\\rm   Teoria revisada corregida\n \\color[rgb]{%s}\\epsilon_E = %4.3f | C_E = %4.3f | R^2_{adj} = %4.2f \n C_D = %4.3f | R^2_{adj} = %4.2f \n \\color{white}.','a',t0,ColUteo,ee,Ce,gofE.adjrsquare,Cd,gofD.adjrsquare);
    leyenda{4} = sprintf('\\bf%d ms %s\\rm   Teoria revisada corregida\n \\color[rgb]{%s}\\epsilon_L = %4.3f | C_L = %4.3f | R^2_{adj} = %4.2f',t0,'a infinito',ColLteo,el,Cl,gofL.adjrsquare);
    
    
    % Obtener punto de cruce
    CortesInd = find(abs(Pdeplot-Plateplot)<=(0.01));
    if ~isnan(CortesInd)
        DistCorteTeo = Distplot(CortesInd(1));
        text(DistCorteTeo,Pdeplot(CortesInd(1))-1,...
            {'Teórica',strcat('\bf\color{magenta}',[sprintf('%4.3f',DistCorteTeo),' m'])},...
            'VerticalAlignment','bottom','HorizontalAlignment','right')
        plot(DistCorteTeo,Pdeplot(CortesInd(1)),...
        'ko','MarkerFaceColor','magenta','MarkerSize',8)
    end
    
    
end
hold off

lgdw=legend(Curv,leyenda);
% Otros detalles de la grafica
xlabel('Distancia (en metros)')
ylabel('Nivel de presión acústica (dB)')
title('Campos útil y perjudicial');
