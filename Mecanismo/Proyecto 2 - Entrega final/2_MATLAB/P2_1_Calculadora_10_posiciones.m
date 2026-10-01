%% ======================================================================
% SEGUNDO PARCIAL - MECANISMOS  (paso 1 de 2)
% Corre la Calculadora de Mecanismos del grupo (Calculadora_Mecanismos.m)
% en las 10 posiciones del dosificador y guarda la evidencia.
% ======================================================================
% Que hace:
%   1. Abre la calculadora, elige "3. Manivela-Corredera" y mete los datos
%      del mecanismo (a = 35 mm, b = 132 mm, c = -20 mm, omega2, alpha2 = 0).
%   2. Recorre las 10 posiciones (theta2 = 0, 36, ..., 324 grados). En cada una:
%        - guarda la captura de la calculadora (Resultados_MATLAB\Calculadora\captura_XX.png)
%        - usa el boton Exportar de la propia calculadora (Resultados_MATLAB\Calculadora\export_XX.xlsx)
%        - lee de sus tablas theta3, d, mu, omega3, v, alpha3 y a
%   3. Junta las 10 posiciones en Resultados_MATLAB\Calculadora_10_posiciones.xlsx
%   4. Anima una vuelta completa con el deslizador y graba simulacion_calculadora.gif
%      (y, si se puede, simulacion_calculadora.mp4)
%
% Uso: dejar este archivo en la misma carpeta que Calculadora_Mecanismos.m,
%      abrirlo en MATLAB y presionar Ejecutar (F5). Tarda unos minutos por las capturas.
%      Despues correr P2_2_Analisis_Validacion.m

clear; clc; close all;
carpeta = fileparts(mfilename('fullpath'));
if isempty(carpeta), carpeta = pwd; end
res    = fullfile(carpeta, 'Resultados_MATLAB');
salida = fullfile(res, 'Calculadora');
if ~isfolder(salida), mkdir(salida); end
addpath(carpeta);   % la calculadora esta en esta misma carpeta

%% Datos del mecanismo (los mismos de P2_2_Analisis_Validacion.m)
a = 35;  b = 132;  c = -20;
rpm = 30;              % velocidad de diseno; cambiar por la medida en el inciso d)
w2  = rpm*2*pi/60;
al2 = 0;
th2_10 = (0:36:324)';

%% 1. Abrir la calculadora y cargar los datos
antes = findall(groot, 'Type', 'figure');
Calculadora_Mecanismos;
fig = setdiff(findall(groot, 'Type', 'figure'), antes);
fig = fig(1);
campo = @(t) findobj(fig, 'Tag', ['in_' t]);
dd = findobj(fig, 'Tag', 'dd_method');
dd.Value = dd.Items{3};  dd.ValueChangedFcn(dd, []);     % 3. Manivela-Corredera
h = campo('a');   h.Value = a;
h = campo('b');   h.Value = b;
h = campo('c');   h.Value = c;
h = campo('w2');  h.Value = w2;
h = campo('al2'); h.Value = al2;
ft2 = campo('t2');
tp = findobj(fig, 'Tag', 'tbl_pos');
tv = findobj(fig, 'Tag', 'tbl_vel');
ta = findobj(fig, 'Tag', 'tbl_acc');
ganchos = getappdata(fig, 'testHooks');                  % permite exportar sin abrir el dialogo
leer = @(tbl, fila) str2double(tbl.Data{strcmp(tbl.Data(:,1), fila), 2});   % columna "Abierta"

%% 2. Las 10 posiciones
R = zeros(10, 7);
fprintf('Corriendo la calculadora en las 10 posiciones...\n');
for k = 1:10
    ft2.Value = th2_10(k);
    ft2.ValueChangedFcn(ft2, []);      % es el mismo calculo que al escribir el angulo a mano
    drawnow;
    R(k,:) = [leer(tp,'theta3'), leer(tp,'d'), leer(tp,'mu'), ...
              leer(tv,'omega3'), leer(tv,'v corredera'), ...
              leer(ta,'alpha3'), leer(ta,'a corredera')];
    png = fullfile(salida, sprintf('captura_%02d_theta%03d.png', k, th2_10(k)));
    exportapp(fig, png);
    xls = fullfile(salida, sprintf('export_%02d_theta%03d.xlsx', k, th2_10(k)));
    if isfile(xls), delete(xls); end
    try
        ganchos.export(xls);           % boton Exportar de la calculadora
    catch ME
        warning('No se pudo exportar la posicion %d: %s', k, ME.message);
    end
    fprintf('  theta2 = %3d -> theta3 = %8.4f, d = %8.4f mm, v = %9.4f mm/s\n', ...
        th2_10(k), R(k,1), R(k,2), R(k,5));
end

%% 3. Tabla resumen con lo que muestra la calculadora
T = table((1:10)', th2_10, R(:,1), R(:,2), R(:,3), R(:,4), R(:,5), R(:,6), R(:,7), ...
    'VariableNames', {'Pos','theta2 (°)','theta3 (°)','d (mm)','mu (°)', ...
    'omega3 (rad/s)','v corredera (mm/s)','alpha3 (rad/s²)','a corredera (mm/s²)'});
disp(T);
resumen = fullfile(res, 'Calculadora_10_posiciones.xlsx');
try
    if isfile(resumen), delete(resumen); end
    writetable(T, resumen, 'Sheet', 'Calculadora');
    fprintf('Tabla guardada en %s\n', resumen);
catch ME
    warning('No se pudo escribir el Excel resumen: %s', ME.message);
end

%% 4. Simulacion: una vuelta completa con el deslizador de la calculadora
sld = findobj(fig, 'Tag', 'sld_t2');
angs = 0:10:350;
gif = fullfile(res, 'simulacion_calculadora.gif');
if isfile(gif), delete(gif); end
tmp = fullfile(salida, 'frame_tmp.png');
vw = [];
try
    vw = VideoWriter(fullfile(res, 'simulacion_calculadora'), 'MPEG-4');
    vw.FrameRate = 12;  open(vw);
catch
    vw = [];
end
fprintf('Grabando la simulacion (%d cuadros)...\n', numel(angs));
for i = 1:numel(angs)
    sld.Value = angs(i);
    sld.ValueChangingFcn(sld, struct('Value', angs(i)));   % mueve el mecanismo en vivo
    drawnow;
    exportapp(fig, tmp);
    F = imread(tmp);
    F = imresize(F, 900/size(F,2));
    if ~isempty(vw), writeVideo(vw, im2frame(F)); end
    [ind, mapa] = rgb2ind(F, 256);
    if i == 1
        imwrite(ind, mapa, gif, 'gif', 'LoopCount', Inf, 'DelayTime', 0.09);
    else
        imwrite(ind, mapa, gif, 'gif', 'WriteMode', 'append', 'DelayTime', 0.09);
    end
end
if ~isempty(vw), close(vw); end
if isfile(tmp), delete(tmp); end
fprintf('Animacion guardada en %s\n', gif);

%% 5. Datos para el anexo del informe
try
    fid = fopen(fullfile(res, 'calculadora_10pos.json'), 'w');
    fprintf(fid, '%s', jsonencode(struct('th2', th2_10, 'R', R, 'rpm', rpm), 'PrettyPrint', true));
    fclose(fid);
catch
end

delete(fig);
fprintf('Listo. Evidencia en la carpeta Resultados_MATLAB. Ahora corre P2_2_Analisis_Validacion.m\n');
