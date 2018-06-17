function [Pdeplot,Plateplot,Cd,ee,Ce,el,Cl,gofD,gofE,gofL] = ...
    TeoRevCorregida(Dneto,Eneto,Pplot,Distancia,Distplot,W,Q,c,S,V,alpha,Zimp,t0)

% Factor de conversión intensidad->presion
Fac = Zimp/((2*10^-5)^2);
% Mean Free Path
mfp = 4*V/S;
% Tiempo de reverberacion de Eyring
T = 6*log(10)/c * mfp * 1/(-log(1-alpha));
% Tiempo de integracion en segundos
t0 = t0*10^-3;


%% Obtencion de la curvas directo y early
%% Curva del campo directo
% Ordenar valores de distancia de menor a mayor manteniendo su valor de SPl
% asociado
Dist_D = sortrows([Distancia',Dneto]);
% Si tiene distancias duplicadas/iguales se promedia el nivel de las dos
% distancias iguales y elimina el duplicado
[C,~,idx] = unique(Dist_D(:,1),'stable');
val = accumarray(idx,Dist_D(:,2),[],@(x) 10*log10(mean(10.^(x/10))));
Dist_D = [C,val];
% Añadir por extrapolacion valor en la posicion de 0 metros hasta la posicion del
% receptor mas cercano
%V0_0toVal=interp1(Dist_U(:,1),Dist_U(:,2),0,'linear','extrap');
%Dist_U = [[0;V0_0toVal]';Dist_U];
% Separar los valores para graficar y convertirlo en vector fila
Dist = Dist_D(:,1);
Drec = Dist_D(:,2);
% Crear curva potencial. Obtiene coeficientes (Ucoef) y datos de ajuste
% (Ures)
[Dcoef,Dres]=fit(Dist,Drec,'power1');
Dplot=Dcoef.a*Distplot.^Dcoef.b;

%% Curva del campo early
% Ordenar valores de distancia de menor a mayor manteniendo su valor de SPl
% asociado
Dist_E = sortrows([Distancia',Eneto]);
% Si tiene distancias duplicadas/iguales se promedia el nivel de las dos
% distancias iguales y elimina el duplicado
[C,~,idx] = unique(Dist_E(:,1),'stable');
val = accumarray(idx,Dist_E(:,2),[],@(x) 10*log10(mean(10.^(x/10))));
Dist_E = [C,val];
% Añadir por extrapolacion valor en la posicion de 0 metros hasta la posicion del
% receptor mas cercano
%V0_0toVal=interp1(Dist_U(:,1),Dist_U(:,2),0,'linear','extrap');
%Dist_U = [[0;V0_0toVal]';Dist_U];
% Separar los valores para graficar y convertirlo en vector fila
Dist = Dist_E(:,1);
Erec = Dist_E(:,2);
% Crear curva potencial. Obtiene coeficientes (Ucoef) y datos de ajuste
% (Ures)
[Ecoef,Eres]=fit(Dist,Erec,'power1');
Eplot=Ecoef.a*Distplot.^Ecoef.b;

% Para no mostrar errores cuando se repite el calculo de coeficientes
warning ('off','all');

%% Calculo de coeficiente para el campo directo
for ii = 1:200 % 200 intentos de obtener los coeficientes
    try % Intenta el calculo con puntos de inicio random
        opD = fitoptions('Method','NonlinearLeastSquares',...
            'Robust','LAR',...
            'Lower',[0,0],...   % Minimo valor de los coeficientes
            'Upper',[20,20],... % Maximo valor de los coeficientes
            'MaxFunEvals',3000,...
            'MaxIter',3000,...
            'TolFun',10^-3);
        fD = fittype('Fac * W*Q./(4*pi*dist.^2)*Cd',...
            'dependent',{'y'},...
            'independent',{'dist'},...
            'problem', {'Q','W','Fac'},...
            'coefficients',{'Cd'},...
            'options',opD);
        [fitiD,gofD,outputD] = fit(Distplot',10.^(Dplot'/10),fD,'problem',{Q,W,Fac});
        break;
    catch % Si no se ha podido obtener unos coeficientes ejecuta lo siguiente
        if ii==200
            hold off
            ed = errordlg('No se ha podido obtener coeficientes (Directo), intentalo de nuevo','Error');
            set(ed, 'WindowStyle', 'modal');
            uiwait(ed);
            return;
        end
    end
end


%% Calculo de coeficientes epsilon y Cl para campo late
for ii = 1:200 % 200 intentos de obtener los coeficientes
    try % Intenta el calculo con puntos de inicio random
        fL = fittype('Fac * (4*W)/(S*(-log(1-alpha))) * exp(-(13.82*(dist/c+t0)*el/T)) * Cl',...
            'dependent',{'y'},...
            'independent',{'dist'},...
            'problem', {'W','S','alpha','t0','T','c','Fac'},...
            'coefficients',{'el','Cl'});
        [fitiL,gofL,outputL] = fit(Distplot',10.^(Pplot'/10),fL,'problem',{W,S,alpha,t0,T,c,Fac});
        break;
    catch % Si no se ha podido obtener unos coeficientes ejecuta lo siguiente
        if ii==200
            hold off
            ed = errordlg('No se ha podido obtener coeficientes (Late), intentalo de nuevo','Error');
            set(ed, 'WindowStyle', 'modal');
            uiwait(ed);
            return;
        end
    end
end

%% Calculo de coeficientes epsilon y Ce para campo early
for ii = 1:200 % 200 intentos de obtener los coeficientes
    try % Intenta el calculo con puntos de inicio random
        opE = fitoptions('Method','NonlinearLeastSquares',...
            'Robust','LAR',...
            'MaxFunEvals',3000,...
            'MaxIter',3000,...
            'TolFun',10^-3);
        fE = fittype('Fac * ((4*W)./(S*(-log(1-alpha))*dist) .* (exp(-(13.82*(dist/c)*ee/T))*Ce - exp(-(13.82*(dist/c+t0)*el/T)) * Cl))',...
            'dependent',{'y'},...
            'independent',{'dist'},...
            'problem', {'W','S','alpha','T','t0','c','Fac','el','Cl'},...
            'coefficients',{'ee','Ce'},...
            'options',opE);
        [fitiE,gofE,outputE] = fit(Distplot',10.^(Eplot'/10),fE,'problem',{W,S,alpha,T,t0,c,Fac,fitiL.el,fitiL.Cl});
        break;
    catch % Si no se ha podido obtener unos coeficientes ejecuta lo siguiente
        if ii==200
            hold off
            ed = errordlg('No se ha podido obtener coeficientes (Early), intentalo de nuevo','Error');
            set(ed, 'WindowStyle', 'modal');
            uiwait(ed);
            return;
        end
    end
end
warning ('on','all');

PDplot = 10*log10(Fac * ( W*Q./(4*pi*Distplot.^2)*fitiD.Cd));
Peplot = 10*log10(Fac *(...
    (4*W)./(S*(-log(1-alpha))*Distplot) .* ...
    (exp(-(13.82*(Distplot/c)*fitiE.ee/T))*fitiE.Ce - exp(-(13.82*(Distplot/c+t0)*fitiL.el/T))*fitiL.Cl)));
Pdeplot = 10*log10(10.^(PDplot/10)+10.^(Peplot/10));
Plateplot = 10*log10(Fac .* (4*W)./(S*(-log(1-alpha))) .* exp(-(13.82.*(Distplot./c+t0).*fitiL.el/T)) .* fitiL.Cl);

% Coeficientes
el = fitiL.el;
Cl = fitiL.Cl;
ee = fitiE.ee;
Ce = fitiE.Ce;
Cd = fitiD.Cd;




