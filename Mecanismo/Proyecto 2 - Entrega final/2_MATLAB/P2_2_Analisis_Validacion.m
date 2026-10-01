%% ======================================================================
% SEGUNDO PARCIAL - MECANISMOS  (paso 2 de 2)
% Universidad Rafael Landivar - Ing. Eli Saul De Paz Aldana - entrega 01/10/2026
% Dosificador de tolva movido por un mecanismo manivela-corredera descentrado
% ======================================================================
% Modelo de Inventor: ..\5_Inventor\Ensamblaje.iam
%   a = 35 mm   manivela O2A (rueda naranja, la mueve el motor)
%   b = 132 mm  biela AB (acoplador magenta)
%   c = -20 mm  descentrado: el eje del bloque azul pasa 20 mm por debajo de O2
%   El bloque azul (corredera) es el eslabon de salida.
%
% Convencion (Norton, "Diseno de maquinaria", manivela-corredera):
%   origen en O2, eje x paralelo a la corredera y apuntando hacia ella,
%   mecanismo visto desde el lado de la biela, angulos antihorarios desde +x.
%   theta3 es el angulo del vector que va de B hacia A.
%   d es la distancia horizontal de O2 al pasador B del bloque.
%
% Las ecuaciones cerradas de la funcion cinematicaCerrada son las mismas que usa
% la Calculadora de Mecanismos del grupo (Calculadora_Mecanismos.m, mecanismo
% "3. Manivela-Corredera", solucion "Abierta": funciones solveSliderCrank y sliderState).
%
% Que calcula (una seccion por inciso):
%   a) datos de la sintesis: carrera, puntos muertos, relacion de tiempos,
%      angulo de transmision y grados de libertad
%   d) promedio y dispersion de la velocidad del motor (lo llena el grupo)
%   e) posicion, velocidad y aceleracion en 10 posiciones (ecuaciones cerradas)
%   f) validacion: calculadora del grupo, simulacion numerica en MATLAB y
%      ensamble de Inventor; tabla de % de error y graficas contra el angulo de entrada
%   g) contraste con la medicion en video (si existe medicion_video.csv)
% Todo queda en Resultados_MATLAB\Resultados_Parcial2.xlsx y en los PNG de esa carpeta.
%
% Uso: cambiar los datos de la primera seccion y presionar Ejecutar (F5).
%      (Opcional) correr antes P2_1_Calculadora_10_posiciones.m para que la tabla
%      de validacion incluya tambien los valores que muestra la calculadora.

clear; clc; close all;
carpeta = fileparts(mfilename('fullpath'));
if isempty(carpeta), carpeta = pwd; end
res = fullfile(carpeta, 'Resultados_MATLAB');
if ~isfolder(res), mkdir(res); end

%% ============================== DATOS ==============================
escala = 1;              % 1 = medidas de Inventor. Si imprimen el modelo a la mitad: 0.5
a = 35*escala;           % manivela [mm]
b = 132*escala;          % biela [mm]
c = -20*escala;          % descentrado de la corredera [mm]

rpm_diseno  = 30;        % velocidad de diseno del motor [rpm]
rpm_medidas = [];        % d) mediciones del motor en rpm (minimo 3), p. ej. [n1 n2 n3]
instrumento = 'Pendiente: tacometro optico o video cuadro por cuadro';
sentido = +1;            % +1 antihorario visto desde el lado de la biela; -1 horario
alpha2  = 0;             % el motor gira a velocidad constante

th2_10 = (0:36:324)';    % e) las 10 posiciones de la manivela [grados]

%% ===================== a) DATOS DE LA SINTESIS =====================
if b < a + abs(c)
    error('La manivela no da la vuelta completa: se necesita b >= a + |c|.');
end
d_max   = sqrt((a+b)^2 - c^2);           % punto muerto exterior (bloque lo mas lejos de O2)
d_min   = sqrt((b-a)^2 - c^2);           % punto muerto interior (bloque lo mas cerca)
carrera = d_max - d_min;
th_ext  = mod(asind(c/(a+b)), 360);       % theta2 en el punto muerto exterior
th_int  = mod(180 + asind(c/(b-a)), 360); % theta2 en el punto muerto interior
% Avance = el bloque se aleja de O2 (empuja el material): va de th_int a th_ext.
giro_int_a_ext = mod(th_ext - th_int, 360);   % grados de manivela si gira antihorario
if sentido > 0
    ang_avance = giro_int_a_ext;
else
    ang_avance = 360 - giro_int_a_ext;
end
ang_retorno = 360 - ang_avance;
Q = ang_avance/ang_retorno;                % relacion de tiempos avance/retorno
mu_min = 90 - asind((a + abs(c))/b);       % peor angulo de transmision
th_mu_min = 90 + 180*(c > 0);              % ocurre con la manivela perpendicular a la corredera
M = 3*(4-1) - 2*4;                         % Gruebler: 4 eslabones y 4 juntas completas

fprintf('==================== a) SINTESIS ====================\n');
fprintf('a = %.2f mm, b = %.2f mm, c = %.2f mm (escala %.2f)\n', a, b, c, escala);
fprintf('Grados de libertad (Gruebler): M = 3(4-1) - 2(4) = %d\n', M);
fprintf('Vuelta completa: b = %.1f >= a + |c| = %.1f -> si\n', b, a + abs(c));
fprintf('Punto muerto interior: theta2 = %7.2f, d = %.2f mm\n', th_int, d_min);
fprintf('Punto muerto exterior: theta2 = %7.2f, d = %.2f mm\n', th_ext, d_max);
fprintf('Carrera = %.2f mm\n', carrera);
fprintf('Avance %.2f, retorno %.2f -> Q = %.4f\n', ang_avance, ang_retorno, Q);
fprintf('Angulo de transmision minimo = %.2f grados (en theta2 = %d)\n\n', mu_min, th_mu_min);

%% ===================== d) VELOCIDAD DEL MOTOR =====================
n_med = numel(rpm_medidas);
rpm_prom = NaN; rpm_desv = NaN; rpm_cv = NaN; rpm_u95 = NaN;
if n_med >= 1, rpm_prom = mean(rpm_medidas); end
if n_med >= 2
    rpm_desv = std(rpm_medidas);                           % desviacion estandar muestral (n-1)
    rpm_cv   = 100*rpm_desv/rpm_prom;                      % coeficiente de variacion [%]
    rpm_u95  = tStudent95(n_med-1)*rpm_desv/sqrt(n_med);   % incertidumbre del promedio (95 %)
end
if n_med >= 3
    rpm_uso = rpm_prom;   fuente_w2 = sprintf('promedio de %d mediciones', n_med);
else
    rpm_uso = rpm_diseno; fuente_w2 = 'velocidad de diseno (todavia no hay 3 mediciones)';
end
w2 = sentido*rpm_uso*2*pi/60;    % [rad/s]

fprintf('================ d) VELOCIDAD DEL MOTOR ================\n');
if n_med == 0
    fprintf('Sin mediciones todavia. Se usa la velocidad de diseno: %.2f rpm.\n', rpm_diseno);
else
    fprintf('Mediciones [rpm]: %s\n', num2str(rpm_medidas, '%.2f '));
    fprintf('Promedio = %.3f rpm, desviacion = %.3f rpm, CV = %.2f %%, U95 = +/- %.3f rpm\n', ...
        rpm_prom, rpm_desv, rpm_cv, rpm_u95);
    fprintf('Instrumento: %s\n', instrumento);
end
fprintf('omega2 usada = %.4f rad/s (%s)\n\n', w2, fuente_w2);

%% ============ e) 10 POSICIONES CON LAS ECUACIONES CERRADAS ============
E = cinematicaCerrada(th2_10, a, b, c, w2, alpha2);
Te = table((1:10)', th2_10, E.th3, E.d, E.mu, E.w3, E.v, E.al3, E.acc, ...
    'VariableNames', {'Pos','theta2 (°)','theta3 (°)','d (mm)','mu (°)', ...
    'omega3 (rad/s)','V_B (mm/s)','alpha3 (rad/s²)','A_B (mm/s²)'});
fprintf('============== e) 10 POSICIONES (analitico) ==============\n');
fprintf('|V_A| = a*|omega2| = %.3f mm/s y |A_A| = a*omega2^2 = %.3f mm/s^2 en todas las posiciones\n', ...
    a*abs(w2), a*w2^2);
disp(Te);

%% ===================== f) VALIDACION COMPUTACIONAL =====================
% f.1 Simulacion numerica en MATLAB, independiente de las formulas de e):
%     en cada instante se resuelve el lazo con Newton-Raphson y las velocidades y
%     aceleraciones salen de derivar numericamente (diferencias centrales).
if alpha2 ~= 0
    warning('La simulacion supone velocidad constante del motor (alpha2 = 0).');
end
N   = 720;                       % pasos por vuelta (0.5 grados por paso)
dth = 360/N;
th2s = (0:N-1)'*dth;
dt  = deg2rad(dth)/w2;           % tiempo entre pasos (negativo si gira horario)
th3s = zeros(N,1);  ds = zeros(N,1);
x = [pi; a + b];                 % suposicion inicial: bloque a la derecha de O2
for k = 1:N
    x = newtonCierre(th2s(k), x, a, b, c);
    th3s(k) = x(1);  ds(k) = x(2);
end
th3s = unwrap(th3s);
sig = @(f) circshift(f,-1);  ant = @(f) circshift(f,1);   % el movimiento es periodico
w3s  = (sig(th3s) - ant(th3s))/(2*dt);
al3s = (sig(th3s) - 2*th3s + ant(th3s))/dt^2;
vs   = (sig(ds) - ant(ds))/(2*dt);
as   = (sig(ds) - 2*ds + ant(ds))/dt^2;
iS = round(th2_10/dth) + 1;
S.th3 = mod(rad2deg(th3s(iS)),360);  S.d = ds(iS);  S.w3 = w3s(iS);
S.v = vs(iS);  S.al3 = al3s(iS);  S.acc = as(iS);

% f.2 Ensamble de Inventor: la manivela se giro a cada angulo (+-0.5 grados) y se midieron
%     los centros de los pasadores; velocidad y aceleracion por diferencias centrales.
archivo10 = fullfile(carpeta, 'datos_inventor_10pos.csv');
hayInv = isfile(archivo10);
I = [];
if hayInv
    D = readmatrix(archivo10, 'NumHeaderLines', 2);
    D(:,2:end) = D(:,2:end)*escala;
    h = deg2rad(0.5);
    I = struct('th3',nan(10,1),'d',nan(10,1),'w3',nan(10,1),'v',nan(10,1), ...
               'al3',nan(10,1),'acc',nan(10,1),'c',nan(10,1));
    for k = 1:10
        f = sortrows(D(abs(D(:,1) - th2_10(k)) <= 1 + 1e-9, :), 1);   % 5 filas: -1, -0.5, 0, +0.5, +1
        t3 = deg2rad(mod(atan2d(f(:,3) - f(:,5), f(:,2) - f(:,4)), 360));
        dd = f(:,6);
        I.th3(k) = rad2deg(t3(3));  I.d(k) = dd(3);  I.c(k) = f(3,7);
        dt3 = (t3(4) - t3(2))/(2*h);   d2t3 = (t3(4) - 2*t3(3) + t3(2))/h^2;
        dd1 = (dd(4) - dd(2))/(2*h);   dd2  = (dd(4) - 2*dd(3) + dd(2))/h^2;
        I.w3(k)  = dt3*w2;   I.al3(k) = d2t3*w2^2 + dt3*alpha2;
        I.v(k)   = dd1*w2;   I.acc(k) = dd2*w2^2 + dd1*alpha2;
    end
end

% f.3 Calculadora de Mecanismos del grupo (resultado de P2_1_Calculadora_10_posiciones.m).
%     Muestra 4 decimales en pantalla, asi que su "error" es solo de redondeo.
archivoCalc = fullfile(res, 'Calculadora_10_posiciones.xlsx');
hayCalc = false;  K = [];
if isfile(archivoCalc)
    try
        Rc = readmatrix(archivoCalc);          % Pos, th2, th3, d, mu, w3, v, al3, a
        Rc = Rc(all(isfinite(Rc(:,1:2)),2), :);
        if size(Rc,1) == 10 && size(Rc,2) >= 9 && all(abs(Rc(:,2) - th2_10) < 1e-6)
            K.th3 = Rc(:,3);  K.d = Rc(:,4);  K.w3 = Rc(:,6);
            K.v = Rc(:,7);    K.al3 = Rc(:,8); K.acc = Rc(:,9);
            hayCalc = true;
        end
    catch ME
        warning('No se pudo leer %s: %s', archivoCalc, ME.message);
    end
end

% Tabla comparativa y porcentaje de error
vars   = {'th3','d','w3','v','al3','acc'};
nombre = {'theta3','d','omega3','V_B','alpha3','A_B'};
unidad = {'°','mm','rad/s','mm/s','rad/s²','mm/s²'};
Tcomp = table((1:10)', th2_10, 'VariableNames', {'Pos','theta2 (°)'});
Terr  = Tcomp;
for j = 1:numel(vars)
    va = E.(vars{j});  vsim = S.(vars{j});
    Tcomp.([nombre{j} ' analítico (' unidad{j} ')']) = va;
    Tcomp.([nombre{j} ' MATLAB (' unidad{j} ')'])    = vsim;
    Terr.([nombre{j} ' MATLAB (%)']) = errPct(vsim, va);
    if hayInv
        vinv = I.(vars{j});
        Tcomp.([nombre{j} ' Inventor (' unidad{j} ')']) = vinv;
        Terr.([nombre{j} ' Inventor (%)']) = errPct(vinv, va);
    end
    if hayCalc
        vcal = K.(vars{j});
        Tcomp.([nombre{j} ' Calculadora (' unidad{j} ')']) = vcal;
        Terr.([nombre{j} ' Calculadora (%)']) = errPct(vcal, va);
    end
end
fprintf('============ f) PORCENTAJE DE ERROR (respecto al analitico) ============\n');
disp(Terr);
errMax = max(max(table2array(Terr(:,3:end))));
fprintf('Error maximo de toda la tabla: %.2e %%\n', errMax);
if hayInv
    fprintf('Descentrado medido en Inventor: %.6f mm (esperado %.2f mm)\n', mean(I.c), c);
end
if ~hayCalc
    fprintf('(Para incluir la calculadora en la tabla, corre antes P2_1_Calculadora_10_posiciones.m)\n');
end
fprintf('\n');

%% ============================ GRAFICAS ============================
thc = (0:0.5:360)';
try, s = settings; s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = 'light'; catch, end  % graficas claras para el informe
Ec = cinematicaCerrada(thc, a, b, c, w2, alpha2);
azul = [0.00 0.45 0.74];  naranja = [0.85 0.33 0.10];  verde = [0.13 0.55 0.13];  gris = [0.4 0.4 0.4];
leyendas = {'Analítico (ecuaciones cerradas)','Simulación MATLAB','10 posiciones (inciso e)'};
if hayInv, leyendas{end+1} = 'Inventor (10 posiciones)'; end

% Figura 1: velocidad y aceleracion angular de la biela (lo que pide el inciso f)
fig1 = figure('Color','w','Position',[80 80 900 720]);
tl = tiledlayout(fig1, 2, 1, 'TileSpacing','compact','Padding','compact');
title(tl, sprintf('Biela: velocidad y aceleración angular  (\\omega_2 = %.3f rad/s)', w2), 'FontWeight','bold');
graficaVariable(nexttile(tl), thc, Ec.w3, th2s, w3s, th2_10, E.w3, hayInv, th2_10, I, 'w3', ...
    '\omega_3 (rad/s)', azul, naranja, verde, leyendas);
graficaVariable(nexttile(tl), thc, Ec.al3, th2s, al3s, th2_10, E.al3, hayInv, th2_10, I, 'al3', ...
    '\alpha_3 (rad/s^2)', azul, naranja, verde, {});
xlabel(tl, '\theta_2, ángulo de la manivela (grados)');
exportgraphics(fig1, fullfile(res, 'f_omega3_alpha3.png'), 'Resolution', 200);

% Figura 2: posicion, velocidad y aceleracion del bloque (eslabon de salida)
fig2 = figure('Color','w','Position',[100 60 900 900]);
tl2 = tiledlayout(fig2, 3, 1, 'TileSpacing','compact','Padding','compact');
title(tl2, 'Bloque (corredera): posición, velocidad y aceleración', 'FontWeight','bold');
graficaVariable(nexttile(tl2), thc, Ec.d, th2s, ds, th2_10, E.d, hayInv, th2_10, I, 'd', ...
    'd (mm)', azul, naranja, verde, leyendas);
graficaVariable(nexttile(tl2), thc, Ec.v, th2s, vs, th2_10, E.v, hayInv, th2_10, I, 'v', ...
    'V_B (mm/s)', azul, naranja, verde, {});
graficaVariable(nexttile(tl2), thc, Ec.acc, th2s, as, th2_10, E.acc, hayInv, th2_10, I, 'acc', ...
    'A_B (mm/s^2)', azul, naranja, verde, {});
xlabel(tl2, '\theta_2, ángulo de la manivela (grados)');
exportgraphics(fig2, fullfile(res, 'f_bloque_d_v_a.png'), 'Resolution', 200);

% Figura 3: angulo de transmision
fig3 = figure('Color','w','Position',[120 120 900 380]);
ax3 = axes(fig3); hold(ax3,'on'); grid(ax3,'on'); box(ax3,'on');
plot(ax3, thc, Ec.mu, 'Color', azul, 'LineWidth', 1.8);
yline(ax3, 45, '--', 'Color', naranja, 'LineWidth', 1.2, 'Label', 'mínimo recomendado 45°');
plot(ax3, th_mu_min, mu_min, 'o', 'MarkerFaceColor', naranja, 'MarkerEdgeColor', 'k');
text(ax3, th_mu_min + 6, mu_min - 2, sprintf('\\mu_{mín} = %.1f°', mu_min));
xlim(ax3, [0 360]); xticks(ax3, 0:36:360); ylim(ax3, [0 95]);
xlabel(ax3, '\theta_2 (grados)'); ylabel(ax3, '\mu (grados)');
title(ax3, 'Ángulo de transmisión', 'FontWeight','bold');
exportgraphics(fig3, fullfile(res, 'a_angulo_transmision.png'), 'Resolution', 200);

% Figura 4: esquema del mecanismo en las 10 posiciones
fig4 = figure('Color','w','Position',[60 40 1000 1150]);
tl4 = tiledlayout(fig4, 5, 2, 'TileSpacing','compact','Padding','compact');
title(tl4, 'Mecanismo en las 10 posiciones calculadas', 'FontWeight','bold');
for k = 1:10
    dibujarMecanismo(nexttile(tl4), a, b, c, th2_10(k), E.th3(k), E.d(k), d_min, d_max, k, azul, verde, naranja, gris);
end
exportgraphics(fig4, fullfile(res, 'e_esquema_10_posiciones.png'), 'Resolution', 200);

%% ===================== g) CONTRASTE EXPERIMENTAL =====================
% medicion_video.csv: exportado de Tracker (o Kinovea), con encabezados en la primera fila:
%   t   -> tiempo [s]
%   x   -> posicion del bloque a lo largo de la corredera [mm]
%   th2 -> (opcional) angulo de la marca de la manivela [grados], medido como en este script
% (ver plantilla_medicion_video.csv)
Texp = table();
archivoVid = fullfile(carpeta, 'medicion_video.csv');
fprintf('================ g) CONTRASTE EXPERIMENTAL ================\n');
if n_med >= 3
    fprintf('omega2 medida %.3f rpm contra diseno %.3f rpm: diferencia %.2f %%\n', ...
        rpm_prom, rpm_diseno, 100*(rpm_prom - rpm_diseno)/rpm_diseno);
end
if isfile(archivoVid)
    V = readtable(archivoVid);
    tv = V.t(:);  xv = V.x(:);
    ok = isfinite(tv) & isfinite(xv);  tv = tv(ok);  xv = xv(ok);
    carrera_exp = max(xv) - min(xv);
    % Teoria: desplazamiento medido desde el punto muerto interior
    if ismember('th2', V.Properties.VariableNames)
        th2v = V.th2(ok);
    else
        % Sin angulo en el video: se busca la fase que mejor ajusta, con la omega2 usada
        fases = (0:0.25:359.75)';
        rms_f = zeros(size(fases));
        for k = 1:numel(fases)
            dk = cinematicaCerrada(mod(fases(k) + rad2deg(w2*(tv - tv(1))), 360), a, b, c, w2, alpha2).d - d_min;
            rms_f(k) = min(rms(dk - (xv - min(xv))), rms(dk - (max(xv) - xv)));
        end
        [~, kb] = min(rms_f);
        th2v = mod(fases(kb) + rad2deg(w2*(tv - tv(1))), 360);
    end
    teo = cinematicaCerrada(th2v, a, b, c, w2, alpha2).d - d_min;
    x1 = xv - min(xv);  x2 = max(xv) - xv;        % el eje x de Tracker puede ir al reves
    if rms(teo - x2) < rms(teo - x1), xexp = x2; else, xexp = x1; end
    err = xexp - teo;
    fprintf('Carrera medida %.2f mm contra teorica %.2f mm: error %.2f %%\n', ...
        carrera_exp, carrera, 100*(carrera_exp - carrera)/carrera);
    fprintf('Error RMS de la posicion: %.2f mm (%.2f %% de la carrera); error maximo %.2f mm\n', ...
        rms(err), 100*rms(err)/carrera, max(abs(err)));
    Texp = table(tv, th2v, xexp, teo, err, 'VariableNames', ...
        {'t (s)','theta2 (°)','x medido (mm)','x teórico (mm)','diferencia (mm)'});
    fig5 = figure('Color','w','Position',[140 140 900 420]);
    ax5 = axes(fig5); hold(ax5,'on'); grid(ax5,'on'); box(ax5,'on');
    plot(ax5, tv, teo, '-', 'Color', azul, 'LineWidth', 1.8);
    plot(ax5, tv, xexp, 'o', 'Color', naranja, 'MarkerSize', 4);
    xlabel(ax5, 't (s)'); ylabel(ax5, 'desplazamiento desde el punto muerto interior (mm)');
    legend(ax5, {'Teórico','Medido en video'}, 'Location', 'best');
    title(ax5, sprintf('Contraste experimental: carrera medida %.1f mm, teórica %.1f mm', carrera_exp, carrera));
    exportgraphics(fig5, fullfile(res, 'g_contraste_video.png'), 'Resolution', 200);
else
    fprintf('Todavia no hay medicion_video.csv. Cuando lo tengan, vuelvan a ejecutar el script.\n');
end
fprintf('\n');

%% ============================ EXCEL ============================
xls = fullfile(res, 'Resultados_Parcial2.xlsx');
Ta = table( ...
    {'Manivela a';'Biela b';'Descentrado c';'Escala del modelo';'Grados de libertad (Gruebler)'; ...
     'd en punto muerto interior';'theta2 en punto muerto interior';'d en punto muerto exterior'; ...
     'theta2 en punto muerto exterior';'Carrera';'Ángulo de avance';'Ángulo de retorno'; ...
     'Relación de tiempos Q';'Ángulo de transmisión mínimo';'theta2 del ángulo mínimo'}, ...
    [a; b; c; escala; M; d_min; th_int; d_max; th_ext; carrera; ang_avance; ang_retorno; Q; mu_min; th_mu_min], ...
    {'mm';'mm';'mm';'-';'-';'mm';'°';'mm';'°';'mm';'°';'°';'-';'°';'°'}, ...
    'VariableNames', {'Parámetro','Valor','Unidad'});
Td = table({'Mediciones (rpm)';'Instrumento';'Promedio (rpm)';'Desviación estándar (rpm)'; ...
     'Coeficiente de variación (%)';'Incertidumbre del promedio, 95 % (rpm)';'omega2 usada (rad/s)';'Origen de omega2'}, ...
    {num2str(rpm_medidas, '%.2f '); instrumento; rpm_prom; rpm_desv; rpm_cv; rpm_u95; w2; fuente_w2}, ...
    'VariableNames', {'Dato','Valor'});
try
    if isfile(xls), delete(xls); end
    writetable(Ta, xls, 'Sheet', 'a_Sintesis');
    writetable(Td, xls, 'Sheet', 'd_Motor');
    writetable(Te, xls, 'Sheet', 'e_10_posiciones');
    writetable(Tcomp, xls, 'Sheet', 'f_Comparacion');
    writetable(Terr, xls, 'Sheet', 'f_Error_%');
    Tcurva = table(thc, Ec.th3, Ec.d, Ec.mu, Ec.w3, Ec.v, Ec.al3, Ec.acc, 'VariableNames', ...
        {'theta2 (°)','theta3 (°)','d (mm)','mu (°)','omega3 (rad/s)','V_B (mm/s)','alpha3 (rad/s²)','A_B (mm/s²)'});
    writetable(Tcurva, xls, 'Sheet', 'Curva_completa');
    if ~isempty(Texp), writetable(Texp, xls, 'Sheet', 'g_Experimental'); end
    fprintf('Resultados guardados en %s\n', xls);
catch ME
    warning('No se pudo escribir el Excel (¿esta abierto?): %s', ME.message);
end

%% ======================== FUNCIONES LOCALES ========================
function R = cinematicaCerrada(th2, a, b, c, w2, al2)
% Manivela-corredera descentrada, rama con la corredera a la derecha de O2 (Norton).
% Mismas ecuaciones que solveSliderCrank/sliderState de Calculadora_Mecanismos.m (solucion Abierta).
    s = (a*sind(th2) - c)/b;
    R.th3 = 180 - asind(s);                                                       % [grados]
    R.d   = a*cosd(th2) - b*cosd(R.th3);                                          % [mm]
    R.mu  = 90 - asind(abs(s));                                                   % angulo de transmision [grados]
    R.w3  = a*w2*cosd(th2)./(b*cosd(R.th3));                                      % [rad/s]
    R.v   = -a*w2*sind(th2) + b*R.w3.*sind(R.th3);                                % [mm/s]
    R.al3 = (a*al2*cosd(th2) - a*w2^2*sind(th2) + b*R.w3.^2.*sind(R.th3))./(b*cosd(R.th3));   % [rad/s^2]
    R.acc = -a*al2*sind(th2) - a*w2^2*cosd(th2) + b*R.al3.*sind(R.th3) + b*R.w3.^2.*cosd(R.th3); % [mm/s^2]
end

function x = newtonCierre(th2, x, a, b, c)
% Resuelve a*cos(th2) - b*cos(th3) - d = 0  y  a*sin(th2) - b*sin(th3) - c = 0  (x = [th3 en rad; d]).
    t2 = deg2rad(th2);
    for it = 1:50
        f  = [a*cos(t2) - b*cos(x(1)) - x(2);  a*sin(t2) - b*sin(x(1)) - c];
        J  = [b*sin(x(1)), -1;  -b*cos(x(1)), 0];
        dx = -J\f;
        x  = x + dx;
        if norm(dx) < 1e-13, return; end
    end
    error('Newton-Raphson no convergio en theta2 = %.2f grados.', th2);
end

function e = errPct(valor, referencia)
    e = 100*abs(valor - referencia)./abs(referencia);
end

function t = tStudent95(gl)
% t de Student bilateral al 95 % para gl grados de libertad
    tab = [12.706 4.303 3.182 2.776 2.571 2.447 2.365 2.306 2.262 2.228 ...
           2.201 2.179 2.160 2.145 2.131 2.120 2.110 2.101 2.093 2.086];
    if gl <= numel(tab), t = tab(gl); else, t = 1.96; end
end

function graficaVariable(ax, thc, yc, ths, ys, th10, y10, hayInv, thI, I, campo, etiqueta, c1, c2, c3, leyendas)
    hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    plot(ax, thc, yc, '-', 'Color', c1, 'LineWidth', 2);
    plot(ax, [ths; 360], [ys; ys(1)], '--', 'Color', c2, 'LineWidth', 1.3);
    plot(ax, th10, y10, 'o', 'MarkerSize', 8, 'MarkerFaceColor', c3, 'MarkerEdgeColor', 'k');
    if hayInv
        plot(ax, thI, I.(campo), 'x', 'MarkerSize', 11, 'LineWidth', 1.8, 'Color', 'k');
    end
    xlim(ax, [0 360]); xticks(ax, 0:36:360);
    ylabel(ax, etiqueta);
    if ~isempty(leyendas), legend(ax, leyendas, 'Location', 'best'); end
end

function dibujarMecanismo(ax, a, b, c, th2, th3, d, d_min, d_max, k, cMan, cBiela, cBloque, cGris)
    hold(ax,'on'); axis(ax,'equal'); box(ax,'on');
    A = [a*cosd(th2), a*sind(th2)];
    B = [d, c];
    % eje de la corredera y carrera
    plot(ax, [-a-10, d_max+30], [c c], ':', 'Color', cGris);
    plot(ax, [d_min d_max], [c c], '-', 'Color', [cGris 0.35], 'LineWidth', 6);
    % bloque
    w = 30; hgt = 22;
    patch(ax, B(1) + [-w/2 w/2 w/2 -w/2], B(2) + [-hgt/2 -hgt/2 hgt/2 hgt/2], cBloque, ...
        'FaceAlpha', 0.35, 'EdgeColor', cBloque, 'LineWidth', 1.2);
    % circulo de la manivela
    tt = linspace(0, 2*pi, 90);
    plot(ax, a*cos(tt), a*sin(tt), ':', 'Color', cGris);
    plot(ax, [0 A(1)], [0 A(2)], '-', 'Color', cMan, 'LineWidth', 3);
    plot(ax, [A(1) B(1)], [A(2) B(2)], '-', 'Color', cBiela, 'LineWidth', 3);
    plot(ax, [0 A(1) B(1)], [0 A(2) B(2)], 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 5);
    plot(ax, 0, 0, 'k^', 'MarkerFaceColor', cGris, 'MarkerSize', 8);
    title(ax, sprintf('%d)  \\theta_2 = %d°   \\theta_3 = %.1f°   d = %.1f mm', k, th2, th3, d), 'FontSize', 9);
    xlim(ax, [-a-15, d_max+25]); ylim(ax, [-a-20, a+15]);
    ax.XTick = []; ax.YTick = [];
end
