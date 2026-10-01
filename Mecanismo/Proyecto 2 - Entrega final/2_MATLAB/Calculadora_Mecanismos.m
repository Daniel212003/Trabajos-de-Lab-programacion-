function Calculadora_Mecanismos
% CALCULADORA DE MECANISMOS - v5.0
% Analisis algebraico completo: posicion, velocidad y aceleracion.
% Mecanismos: cuatro barras (coordenadas y lazo vectorial), manivela-corredera,
% corredera-manivela y manivela-corredera invertido.
%
% Uso:  >> Calculadora_Mecanismos

%% ================= PALETA =================
bg      = [0.043 0.055 0.090];
panel   = [0.078 0.098 0.149];
panel2  = [0.110 0.137 0.200];
white   = [0.94 0.96 1.00];
muted   = [0.55 0.62 0.75];
accent  = [0.25 0.60 1.00];
green   = [0.16 0.80 0.55];
red     = [0.98 0.35 0.42];
orange  = [0.98 0.62 0.20];
purple  = [0.70 0.52 0.99];
cyan    = [0.25 0.85 0.92];

colGround = [0.35 0.40 0.52];
colLink2  = accent;
colLink3  = green;
colLink4  = orange;
colP      = purple;
txtCol    = [0.88 0.91 0.97];

%% ================= VENTANA =================
scr = get(groot,'ScreenSize');
W = min(1720, scr(3)-60);
H = min(980,  scr(4)-90);
fig = uifigure('Name','Calculadora de Mecanismos  |  v5.0', ...
    'Position',[(scr(3)-W)/2 (scr(4)-H)/2 W H],'Color',bg);

root = uigridlayout(fig,[3 3]);
root.RowHeight    = {74,'1x',30};
root.ColumnWidth  = {330,'1x',440};
root.Padding      = [12 10 12 10];
root.RowSpacing   = 10;
root.ColumnSpacing= 10;
root.BackgroundColor = bg;

%% ================= ENCABEZADO =================
header = uipanel(root,'BackgroundColor',panel,'BorderType','none');
header.Layout.Row = 1; header.Layout.Column = [1 3];
hg = uigridlayout(header,[2 6]);
hg.RowHeight   = {30,28};
hg.ColumnWidth = {'1x',230,150,230,95,95};
hg.Padding     = [16 8 14 8];
hg.ColumnSpacing = 10;
hg.BackgroundColor = panel;

lb = uilabel(hg,'Text','CALCULADORA DE MECANISMOS', ...
    'FontSize',21,'FontWeight','bold','FontColor',white);
lb.Layout.Row = 1; lb.Layout.Column = 1;
lb2 = uilabel(hg,'Text','Posicion  ·  Velocidad  ·  Aceleracion  ·  Grashof  ·  Angulo de transmision', ...
    'FontSize',10.5,'FontColor',muted);
lb2.Layout.Row = 2; lb2.Layout.Column = 1;

methodNames = { ...
    '1. Coordenadas - Cuatro Barras', ...
    '2. Lazo Vectorial - Cuatro Barras', ...
    '3. Manivela-Corredera', ...
    '4. Corredera-Manivela', ...
    '5. Manivela-Corredera Invertido'};

mkCap(hg,'Mecanismo',1,2,muted);
methodDD = uidropdown(hg,'Items',methodNames,'Value',methodNames{1}, ...
    'BackgroundColor',panel2,'FontColor',white,'Tag','dd_method');
methodDD.Layout.Row = 2; methodDD.Layout.Column = 2;

mkCap(hg,'Solucion',1,3,muted);
branchDD = uidropdown(hg,'BackgroundColor',panel2,'FontColor',white,'Tag','dd_branch');
branchDD.Layout.Row = 2; branchDD.Layout.Column = 3;

mkCap(hg,'Cargar ejemplo',1,4,muted);
presetNames = { ...
    'Practica 6.A - Fila 1', ...
    'Grashof: Manivela-balancin', ...
    'Grashof: Doble manivela', ...
    'Grashof: Doble balancin', ...
    'No Grashof: Triple balancin'};
presetDD = uidropdown(hg,'Items',presetNames,'Value',presetNames{1}, ...
    'BackgroundColor',panel2,'FontColor',white,'Tag','dd_preset');
presetDD.Layout.Row = 2; presetDD.Layout.Column = 4;

exportBtn = uibutton(hg,'Text','Exportar','BackgroundColor',orange, ...
    'FontColor',[0.12 0.09 0.02],'FontWeight','bold','Tag','btn_export');
exportBtn.Layout.Row = 2; exportBtn.Layout.Column = 5;

helpBtn = uibutton(hg,'Text','Ayuda','BackgroundColor',panel2, ...
    'FontColor',white,'FontWeight','bold','Tag','btn_help');
helpBtn.Layout.Row = 2; helpBtn.Layout.Column = 6;

%% ================= PANEL DE ENTRADAS =================
inPanel = uipanel(root,'Title','  DATOS DE ENTRADA  ','FontWeight','bold','FontSize',11, ...
    'ForegroundColor',white,'BackgroundColor',panel,'BorderType','none');
inPanel.Layout.Row = 2; inPanel.Layout.Column = 1;
ig = uigridlayout(inPanel,[15 2]);
ig.RowHeight   = {34,30,30,30,30,30,52,30,30,30,30,30,'1x',42,32};
ig.ColumnWidth = {150,'1x'};
ig.Padding     = [12 10 12 10];
ig.RowSpacing  = 4;
ig.BackgroundColor = panel;

methodInfo = uilabel(ig,'Text','','FontColor',muted,'WordWrap','on','FontSize',10);
methodInfo.Layout.Row = 1; methodInfo.Layout.Column = [1 2];

fieldNames = {'a','b','c','d','t2','w2','al2','gamma','rpa','phi'};
fieldRows  = [ 2   3   4   5   6    8    9     10      11    12 ];
baseLabels = { ...
    'a  Manivela (mm)', ...
    'b  Acoplador (mm)', ...
    'c  Balancin (mm)', ...
    'd  Bancada (mm)', ...
    'theta2  Angulo entrada (grados)', ...
    'omega2  Vel. angular (rad/s)', ...
    'alpha2  Acel. angular (rad/s^2)', ...
    'gamma  Angulo fijo (grados)', ...
    'RPA  Distancia A a P (mm)', ...
    'phi  Angulo del punto P (grados)'};
defaults = [2 7 9 6 30 10 0 90 6 30];

labels = struct(); fields = struct();
for k = 1:numel(fieldNames)
    nm = fieldNames{k};
    labels.(nm) = uilabel(ig,'Text',baseLabels{k},'FontColor',white,'FontSize',10.5);
    labels.(nm).Layout.Row = fieldRows(k); labels.(nm).Layout.Column = 1;
    fields.(nm) = uieditfield(ig,'numeric','Value',defaults(k),'FontSize',11, ...
        'BackgroundColor',panel2,'FontColor',white,'Tag',['in_' nm]);
    fields.(nm).Layout.Row = fieldRows(k); fields.(nm).Layout.Column = 2;
    fields.(nm).ValueChangedFcn = @(~,~) onInputChanged();
end

t2Slider = uislider(ig,'Limits',[0 360],'Value',defaults(5), ...
    'MajorTicks',0:90:360,'FontColor',muted,'Tag','sld_t2');
t2Slider.Layout.Row = 7; t2Slider.Layout.Column = [1 2];

calcBtn = uibutton(ig,'Text','CALCULAR','BackgroundColor',accent, ...
    'FontColor',[0.02 0.06 0.14],'FontWeight','bold','FontSize',13,'Tag','btn_calc');
calcBtn.Layout.Row = 14; calcBtn.Layout.Column = [1 2];

resetBtn = uibutton(ig,'Text','Restablecer vista','BackgroundColor',panel2, ...
    'FontColor',white,'FontSize',10,'Tag','btn_reset');
resetBtn.Layout.Row = 15; resetBtn.Layout.Column = [1 2];

%% ================= GRAFICA =================
gPanel = uipanel(root,'Title','  ESQUEMA DEL MECANISMO  ','FontWeight','bold','FontSize',11, ...
    'ForegroundColor',white,'BackgroundColor',panel,'BorderType','none');
gPanel.Layout.Row = 2; gPanel.Layout.Column = 2;
gg = uigridlayout(gPanel,[2 1]);
gg.RowHeight = {'1x',40};
gg.Padding   = [10 8 10 8];
gg.RowSpacing= 6;
gg.BackgroundColor = panel;

ax = uiaxes(gg);
ax.Layout.Row = 1;
ax.Color = [0.055 0.070 0.110];
ax.XColor = muted; ax.YColor = muted;
ax.GridColor = [0.25 0.30 0.40]; ax.GridAlpha = 0.55;
ax.XGrid = 'on'; ax.YGrid = 'on'; ax.Box = 'on';
ax.Title.Color = txtCol; ax.XLabel.Color = muted; ax.YLabel.Color = muted;
xlabel(ax,'X (mm)'); ylabel(ax,'Y (mm)');

tb = uigridlayout(gg,[1 6]);
tb.Layout.Row = 2;
tb.ColumnWidth = {96,96,110,'1x',150,130};
tb.Padding = [0 2 0 2]; tb.ColumnSpacing = 8;
tb.BackgroundColor = panel;

animBtn = uibutton(tb,'Text','Animar','BackgroundColor',green, ...
    'FontColor',[0.02 0.10 0.06],'FontWeight','bold','Tag','btn_anim');
animBtn.Layout.Column = 1;
stopBtn = uibutton(tb,'Text','Detener','BackgroundColor',red,'FontColor',white, ...
    'FontWeight','bold','Enable','off','Tag','btn_stop');
stopBtn.Layout.Column = 2;
speedDD = uidropdown(tb,'Items',{'Lento','Normal','Rapido'},'Value','Normal', ...
    'BackgroundColor',panel2,'FontColor',white);
speedDD.Layout.Column = 3;
curveChk = uicheckbox(tb,'Text','Curva del acoplador','Value',true, ...
    'FontColor',muted);
curveChk.Layout.Column = 5;
vecChk = uicheckbox(tb,'Text','Vectores V','Value',false,'FontColor',muted);
vecChk.Layout.Column = 6;

%% ================= COLUMNA DERECHA =================
rightGrid = uigridlayout(root,[3 1]);
rightGrid.Layout.Row = 2; rightGrid.Layout.Column = 3;
rightGrid.RowHeight = {118,132,'1x'};
rightGrid.Padding = [0 0 0 0];
rightGrid.RowSpacing = 10;
rightGrid.BackgroundColor = bg;

% --- tarjetas KPI ---
kpiGrid = uigridlayout(rightGrid,[2 2]);
kpiGrid.Layout.Row = 1;
kpiGrid.Padding = [0 0 0 0];
kpiGrid.RowSpacing = 8; kpiGrid.ColumnSpacing = 8;
kpiGrid.BackgroundColor = bg;
kpi.w3 = makeCard(kpiGrid,'omega3  (rad/s)',cyan);
kpi.w4 = makeCard(kpiGrid,'omega4  (rad/s)',orange);
kpi.vp = makeCard(kpiGrid,'|V_P|  (mm/s)',purple);
kpi.ap = makeCard(kpiGrid,'|A_P|  (mm/s^2)',green);

% --- gauge de transmision + Grashof ---
statPanel = uipanel(rightGrid,'BackgroundColor',panel,'BorderType','none');
statPanel.Layout.Row = 2;
sg = uigridlayout(statPanel,[1 2]);
sg.ColumnWidth = {170,'1x'};
sg.Padding = [10 6 10 6];
sg.BackgroundColor = panel;

gaugeBox = uigridlayout(sg,[2 1]);
gaugeBox.RowHeight = {16,'1x'};
gaugeBox.Padding = [0 0 0 0]; gaugeBox.RowSpacing = 0;
gaugeBox.BackgroundColor = panel;
gl = uilabel(gaugeBox,'Text','ANGULO DE TRANSMISION','FontSize',9, ...
    'FontColor',muted,'HorizontalAlignment','center');
gl.Layout.Row = 1;
muGauge = uigauge(gaugeBox,'semicircular','Limits',[0 90], ...
    'ScaleColors',{red,orange,green},'ScaleColorLimits',[0 30;30 45;45 90], ...
    'BackgroundColor',panel,'FontColor',white,'Tag','gauge_mu');
muGauge.Layout.Row = 2;

gBox = uigridlayout(sg,[4 1]);
gBox.RowHeight = {14,24,'1x',16};
gBox.Padding = [0 4 0 4]; gBox.RowSpacing = 2;
gBox.BackgroundColor = panel;
uilabel(gBox,'Text','CLASIFICACION DE GRASHOF','FontSize',9,'FontColor',muted);
grashofLbl = uilabel(gBox,'Text','--','FontSize',13,'FontWeight','bold', ...
    'FontColor',white,'Tag','lbl_grashof');
grashofTipo = uilabel(gBox,'Text','--','FontSize',11,'FontColor',cyan, ...
    'WordWrap','on','Tag','lbl_tipo');
grashofSums = uilabel(gBox,'Text','','FontSize',9.5,'FontColor',muted,'WordWrap','on');

% --- pestanas de resultados ---
tabs = uitabgroup(rightGrid);
tabs.Layout.Row = 3;
tabPos = uitab(tabs,'Title','Posicion','BackgroundColor',panel);
tabVel = uitab(tabs,'Title','Velocidad','BackgroundColor',panel);
tabAcc = uitab(tabs,'Title','Aceleracion','BackgroundColor',panel);
tabGra = uitab(tabs,'Title','Grashof','BackgroundColor',panel);

posTable = makeTable(tabPos,'tbl_pos',panel,panel2,white);
velTable = makeTable(tabVel,'tbl_vel',panel,panel2,white);
accTable = makeTable(tabAcc,'tbl_acc',panel,panel2,white);
graTable = makeTable(tabGra,'tbl_gra',panel,panel2,white);

%% ================= PIE =================
footer = uipanel(root,'BackgroundColor',panel,'BorderType','none');
footer.Layout.Row = 3; footer.Layout.Column = [1 3];
fgl = uigridlayout(footer,[1 1]); fgl.Padding = [14 2 14 2];
fgl.BackgroundColor = panel;
statusLbl = uilabel(fgl,'Text','Listo','FontColor',green,'FontWeight','bold', ...
    'FontSize',10,'Tag','lbl_status');

%% ================= ESTADO =================
animating  = false;
axBounds   = [];
couplerPts = [];
lastResult = struct();
lastMethod = 1;

%% ================= CALLBACKS =================
methodDD.ValueChangedFcn  = @(~,~) methodChanged();
branchDD.ValueChangedFcn  = @(~,~) fullCalc();
presetDD.ValueChangedFcn  = @(~,~) loadPreset();
calcBtn.ButtonPushedFcn   = @(~,~) fullCalc(true);
resetBtn.ButtonPushedFcn  = @(~,~) resetView();
helpBtn.ButtonPushedFcn   = @(~,~) showHelp();
exportBtn.ButtonPushedFcn = @(~,~) exportResults();
animBtn.ButtonPushedFcn   = @(~,~) animate();
stopBtn.ButtonPushedFcn   = @(~,~) stopAnim();
curveChk.ValueChangedFcn  = @(~,~) fullCalc();
vecChk.ValueChangedFcn    = @(~,~) fullCalc();
t2Slider.ValueChangingFcn = @(~,e) onSlider(e.Value);
t2Slider.ValueChangedFcn  = @(~,~) fullCalc();

% Punto de entrada para pruebas automaticas: permite exportar sin abrir
% el cuadro de dialogo de guardado.
setappdata(fig,'testHooks',struct('export',@exportResults));

methodChanged();

%% ====================================================================
%% ============================ INTERFAZ ==============================
%% ====================================================================

    function m = currentMethod()
        m = find(strcmp(methodDD.Value,methodNames),1);
    end

    function setShown(nm,tf)
        if tf, v = 'on'; else, v = 'off'; end
        labels.(nm).Visible = v;
        fields.(nm).Visible = v;
    end

    function fam = familyOf(m)
        switch m
            case {1,2}, fam = 1;   % cuatro barras
            otherwise,  fam = m;   % cada corredera va por su cuenta
        end
    end

    function loadMethodDefaults(m)
        % Los mecanismos no comparten geometria: al cambiar de familia se
        % cargan medidas validas para que la pantalla nunca abra en error.
        switch m
            case {1,2}
                setVals(2,7,9,6,30,10,0,6,30);
            case 3
                setVals(40,120,-20,6,60,1,0,6,30);
            case 4
                setVals(40,120,-20,126.84,60,1,0,6,30);
            case 5
                setVals(40,7,60,100,45,1,0,6,30);
                fields.gamma.Value = 90;
        end
        t2Slider.Value = mod(fields.t2.Value,360);
    end

    function methodChanged()
        m = currentMethod();
        if familyOf(m) ~= familyOf(lastMethod)
            loadMethodDefaults(m);
        end
        lastMethod = m;
        for ii = 1:numel(fieldNames), setShown(fieldNames{ii},true); end
        for ii = 1:numel(fieldNames)
            labels.(fieldNames{ii}).Text = baseLabels{ii};
        end
        t2Slider.Visible = 'on';
        presetDD.Enable  = 'off';

        switch m
            case 1
                methodInfo.Text = 'Geometria analitica: se resuelve la interseccion de dos circunferencias.';
                setShown('gamma',false);
                branchDD.Items = {'Abierta','Cruzada','Ambas'};
                presetDD.Enable = 'on';
            case 2
                methodInfo.Text = 'Lazo vectorial de Freudenstein con sustitucion de semiangulo.';
                setShown('gamma',false);
                branchDD.Items = {'Abierta','Cruzada','Ambas'};
                presetDD.Enable = 'on';
            case 3
                methodInfo.Text = 'Entrada theta2. c es el descentrado y d la posicion de la corredera.';
                labels.c.Text = 'c  Descentrado (mm)';
                setShown('d',false); setShown('gamma',false);
                setShown('rpa',false); setShown('phi',false);
                branchDD.Items = {'Abierta','Cruzada','Ambas'};
            case 4
                methodInfo.Text = 'Entrada d (posicion de la corredera). Se obtienen las dos ramas del circuito.';
                labels.c.Text = 'c  Descentrado (mm)';
                labels.d.Text = 'd  Posicion corredera (mm)';
                setShown('t2',false); setShown('gamma',false);
                setShown('rpa',false); setShown('phi',false);
                t2Slider.Visible = 'off';
                branchDD.Items = {'Rama 1','Rama 2','Ambas'};
            case 5
                methodInfo.Text = 'Inversion: la longitud b es variable y gamma se mantiene fijo.';
                labels.c.Text = 'c  Eslabon 4 (mm)';
                setShown('b',false);
                setShown('rpa',false); setShown('phi',false);
                branchDD.Items = {'Raiz (-)','Raiz (+)','Ambas'};
        end
        branchDD.Value = branchDD.Items{1};
        axBounds = [];
        fullCalc();
    end

    function onInputChanged()
        t2Slider.Value = mod(fields.t2.Value,360);
        axBounds = [];   % las medidas pudieron cambiar: reencuadrar
        fullCalc();
    end

    function onSlider(v)
        fields.t2.Value = v;
        quickCalc();
    end

    function loadPreset()
        switch presetDD.Value
            case 'Practica 6.A - Fila 1'
                setVals(2,7,9,6,30,10,0,6,30);
            case 'Grashof: Manivela-balancin'
                setVals(2,7,9,6,30,10,0,6,30);
            case 'Grashof: Doble manivela'
                setVals(7,9,6,2,50,10,0,5,30);
            case 'Grashof: Doble balancin'
                setVals(7,2,9,6,90,10,0,4,30);
            case 'No Grashof: Triple balancin'
                setVals(4,5,6,10,60,10,0,4,30);
        end
        t2Slider.Value = fields.t2.Value;
        axBounds = [];
        fullCalc();
    end

    function setVals(a,b,c,d,t2,w2,al2,rpa,phi)
        fields.a.Value=a;   fields.b.Value=b;   fields.c.Value=c;
        fields.d.Value=d;   fields.t2.Value=t2; fields.w2.Value=w2;
        fields.al2.Value=al2; fields.rpa.Value=rpa; fields.phi.Value=phi;
    end

    function showHelp()
        msg = sprintf([ ...
            'COMO SE USA\n\n' ...
            '1. Elige el mecanismo en el desplegable superior.\n' ...
            '2. Escribe las longitudes y el angulo de entrada.\n' ...
            '   Puedes arrastrar el deslizador de theta2 para ver el movimiento en vivo.\n' ...
            '3. Los resultados se actualizan solos; el boton CALCULAR fuerza el recalculo.\n' ...
            '4. Las pestanas de la derecha separan posicion, velocidad, aceleracion y Grashof.\n\n' ...
            'QUE SIGNIFICA CADA COSA\n\n' ...
            'Solucion abierta / cruzada: las dos formas de montar el mismo mecanismo.\n' ...
            'Angulo de transmision: mide la calidad con que se transmite la fuerza.\n' ...
            '   Verde (mayor que 45) es bueno, naranja aceptable, rojo por debajo de 30 es malo.\n' ...
            'Curva del acoplador: trayectoria que recorre el punto P en una vuelta completa.\n\n' ...
            'CONVENIO DE SIGNOS\n\n' ...
            'Los angulos van en grados y se miden desde el eje X positivo.\n' ...
            'Las velocidades y aceleraciones angulares son positivas en sentido antihorario.\n\n' ...
            'El boton Exportar guarda todos los resultados en un archivo de Excel.']);
        uialert(fig,msg,'Ayuda','Icon','info');
    end

    function resetView()
        axBounds = [];
        fullCalc();
    end

%% ====================================================================
%% ============================ CALCULO ===============================
%% ====================================================================

    function fullCalc(showAlert)
        if nargin < 1, showAlert = false; end
        runCalc(showAlert,false);
    end

    function quickCalc()
        runCalc(false,true);
    end

    function runCalc(showAlert,fast)
        try
            a=fields.a.Value; b=fields.b.Value; c=fields.c.Value; d=fields.d.Value;
            t2=fields.t2.Value; w2=fields.w2.Value; al2=fields.al2.Value;
            gam=fields.gamma.Value; rpa=fields.rpa.Value; phi=fields.phi.Value;
            m = currentMethod();

            if a <= 0, error('La longitud a debe ser positiva.'); end

            switch m
                case 1
                    checkFourBar(a,b,c,d);
                    r = solveFourBarCoords(a,b,c,d,t2,w2,al2,rpa,phi);
                case 2
                    checkFourBar(a,b,c,d);
                    r = solveFourBarLoop(a,b,c,d,t2,w2,al2,rpa,phi);
                case 3
                    if b <= 0, error('La longitud b debe ser positiva.'); end
                    r = solveSliderCrank(a,b,c,t2,w2,al2);
                case 4
                    if b <= 0, error('La longitud b debe ser positiva.'); end
                    r = solveDrivenSlider(a,b,c,d,w2);
                case 5
                    if c <= 0, error('La longitud c debe ser positiva.'); end
                    r = solveInverted(a,c,d,t2,gam,w2);
            end
            lastResult = r;

            if ~fast
                fillTables(r,m,a,b,c,d,gam);
                if isempty(axBounds), axBounds = computeBounds(m,a,b,c,d,rpa,phi,gam,w2,al2); end
                couplerPts = [];
                if curveChk.Value && any(m==[1 2])
                    couplerPts = couplerCurve(a,b,c,d,rpa,phi,w2,al2);
                end
            end

            updateCards(r,m);
            drawScene(r,m,a,c,d,t2);

            statusLbl.Text = 'Calculo completado';
            statusLbl.FontColor = green;
        catch ME
            statusLbl.Text = ['Error: ' ME.message];
            statusLbl.FontColor = red;
            if showAlert
                uialert(fig,ME.message,'No se pudo calcular','Icon','warning');
            end
        end
    end

    function checkFourBar(a,b,c,d)
        if any([a b c d] <= 0)
            error('En el cuatro barras las cuatro longitudes deben ser positivas.');
        end
    end

%% ---------------- CUATRO BARRAS: COORDENADAS ----------------

    function r = solveFourBarCoords(a,b,c,d,t2,w2,al2,rpa,phi)
        A = [a*cosd(t2), a*sind(t2)];
        [B1,B2] = circleIntersect(A,b,[d 0],c);
        s1 = fourBarState(a,b,c,d,t2,w2,al2,rpa,phi, ...
                atan2d(B1(2)-A(2),B1(1)-A(1)), atan2d(B1(2),B1(1)-d));
        s2 = fourBarState(a,b,c,d,t2,w2,al2,rpa,phi, ...
                atan2d(B2(2)-A(2),B2(1)-A(1)), atan2d(B2(2),B2(1)-d));
        if B1(2) >= B2(2), r.open = s1; r.cross = s2;
        else,              r.open = s2; r.cross = s1; end
        r.A = A;
    end

    function [B1,B2] = circleIntersect(C1,r1,C2,r2)
        v = C2 - C1; L = hypot(v(1),v(2));
        if L < 1e-12, error('Los pivotes coinciden.'); end
        x  = (r1^2 - r2^2 + L^2)/(2*L);
        h2 = r1^2 - x^2;
        if h2 < -1e-9
            error('Con estas longitudes el mecanismo no cierra en ese angulo.');
        end
        h = sqrt(max(h2,0));
        u = v/L; p = C1 + x*u; perp = [-u(2) u(1)];
        B1 = p + h*perp; B2 = p - h*perp;
    end

%% ---------------- CUATRO BARRAS: LAZO VECTORIAL ----------------

    function r = solveFourBarLoop(a,b,c,d,t2,w2,al2,rpa,phi)
        K1=d/a; K2=d/c; K3=(a^2-b^2+c^2+d^2)/(2*a*c);
        K4=d/b; K5=(c^2-d^2-a^2-b^2)/(2*a*b);
        Ac=cosd(t2)-K1-K2*cosd(t2)+K3;  Bc=-2*sind(t2);  Cc=K1-(K2+1)*cosd(t2)+K3;
        Dc=cosd(t2)-K1+K4*cosd(t2)+K5;  Ec=-2*sind(t2);  Fc=K1+(K4-1)*cosd(t2)+K5;
        [t4m,t4p] = semiAngle(Ac,Bc,Cc);
        [t3m,t3p] = semiAngle(Dc,Ec,Fc);
        r.open  = fourBarState(a,b,c,d,t2,w2,al2,rpa,phi,t3m,t4m);
        r.cross = fourBarState(a,b,c,d,t2,w2,al2,rpa,phi,t3p,t4p);
        r.A = [a*cosd(t2), a*sind(t2)];
        r.K = [K1 K2 K3 K4 K5];
    end

    function [angMinus,angPlus] = semiAngle(A,B,C)
        disc = B^2 - 4*A*C;
        if disc < -1e-9
            error('Con estas longitudes el mecanismo no cierra en ese angulo.');
        end
        disc = max(disc,0);
        if abs(A) < 1e-12
            if abs(B) < 1e-12, error('La ecuacion de cierre degenera.'); end
            angMinus = 2*atand(-C/B); angPlus = angMinus;
        else
            angMinus = 2*atand((-B-sqrt(disc))/(2*A));
            angPlus  = 2*atand((-B+sqrt(disc))/(2*A));
        end
    end

%% ---------------- ESTADO COMPLETO DE UN CUATRO BARRAS ----------------

    function s = fourBarState(a,b,c,d,t2,w2,al2,rpa,phi,t3,t4)
        s.theta3 = t3;
        s.theta4 = t4;
        s.A = [a*cosd(t2), a*sind(t2)];
        s.B = [d + c*cosd(t4), c*sind(t4)];
        s.mu = acuteAngle(t4 - t3);

        den3 = b*sind(t3-t4);
        den4 = c*sind(t4-t3);
        if abs(den3) < 1e-9 || abs(den4) < 1e-9
            s.w3 = NaN; s.w4 = NaN;
        else
            s.w3 = a*w2*sind(t4-t2)/den3;
            s.w4 = a*w2*sind(t2-t3)/den4;
        end

        % Aceleracion angular (Norton, ec. de cierre derivada dos veces)
        den = b*c*sind(t4-t3);
        if abs(den) < 1e-9 || isnan(s.w3)
            s.al3 = NaN; s.al4 = NaN;
        else
            Ap = c*sind(t4);  Bp = b*sind(t3);
            Dp = c*cosd(t4);  Ep = b*cosd(t3);
            Cp = a*al2*sind(t2) + a*w2^2*cosd(t2) + b*s.w3^2*cosd(t3) - c*s.w4^2*cosd(t4);
            Fp = a*al2*cosd(t2) - a*w2^2*sind(t2) - b*s.w3^2*sind(t3) + c*s.w4^2*sind(t4);
            s.al3 = (Cp*Dp - Ap*Fp)/den;
            s.al4 = (Cp*Ep - Bp*Fp)/den;
        end

        % Velocidades y aceleraciones de puntos
        s.VA = [-a*w2*sind(t2), a*w2*cosd(t2)];
        s.AA = [-a*w2^2*cosd(t2) - a*al2*sind(t2), ...
                -a*w2^2*sind(t2) + a*al2*cosd(t2)];
        s.VB = [-c*s.w4*sind(t4), c*s.w4*cosd(t4)];
        s.AB = [-c*s.w4^2*cosd(t4) - c*s.al4*sind(t4), ...
                -c*s.w4^2*sind(t4) + c*s.al4*cosd(t4)];

        ang = t3 + phi;
        s.P  = s.A + rpa*[cosd(ang) sind(ang)];
        s.VP = s.VA + [-rpa*s.w3*sind(ang), rpa*s.w3*cosd(ang)];
        s.AP = s.AA + [-rpa*s.w3^2*cosd(ang) - rpa*s.al3*sind(ang), ...
                       -rpa*s.w3^2*sind(ang) + rpa*s.al3*cosd(ang)];
    end

%% ---------------- MANIVELA-CORREDERA ----------------

    function r = solveSliderCrank(a,b,c,t2,w2,al2)
        x = (a*sind(t2) - c)/b;
        if abs(x) > 1 + 1e-10
            error('Con este descentrado la corredera no alcanza esa posicion.');
        end
        x = max(-1,min(1,x));
        t3c = asind(x);
        t3o = 180 - asind(x);
        r.A = [a*cosd(t2), a*sind(t2)];
        r.open  = sliderState(a,b,c,t2,w2,al2,t3o);
        r.cross = sliderState(a,b,c,t2,w2,al2,t3c);
    end

    function s = sliderState(a,b,c,t2,w2,al2,t3)
        s.theta3 = t3;
        s.d = a*cosd(t2) - b*cosd(t3);
        s.B = [s.d, c];
        s.mu = acuteAngle(t3 - 90);
        if abs(cosd(t3)) < 1e-9
            s.w3 = NaN; s.al3 = NaN; s.vb = NaN; s.ab = NaN;
        else
            s.w3  = a*w2*cosd(t2)/(b*cosd(t3));
            s.vb  = -a*w2*sind(t2) + b*s.w3*sind(t3);
            s.al3 = (a*al2*cosd(t2) - a*w2^2*sind(t2) + b*s.w3^2*sind(t3))/(b*cosd(t3));
            s.ab  = -a*al2*sind(t2) - a*w2^2*cosd(t2) + b*s.al3*sind(t3) + b*s.w3^2*cosd(t3);
        end
        s.VA = [-a*w2*sind(t2), a*w2*cosd(t2)];
        s.AA = [-a*w2^2*cosd(t2) - a*al2*sind(t2), ...
                -a*w2^2*sind(t2) + a*al2*cosd(t2)];
    end

%% ---------------- CORREDERA-MANIVELA ----------------

    function r = solveDrivenSlider(a,b,c,d,w2)
        K1 = a^2 - b^2 + c^2 + d^2; K2 = -2*a*c; K3 = -2*a*d;
        Ac = K1 - K3; Bc = 2*K2; Cc = K1 + K3;
        disc = Bc^2 - 4*Ac*Cc;
        if disc < -1e-9, error('La corredera no alcanza esa posicion.'); end
        disc = max(disc,0);
        if abs(Ac) < 1e-12
            if abs(Bc) < 1e-12, error('La ecuacion de cierre degenera.'); end
            tp = -Cc/Bc; tm = tp;
        else
            tp = (-Bc + sqrt(disc))/(2*Ac);
            tm = (-Bc - sqrt(disc))/(2*Ac);
        end
        r.rama1 = drivenBranch(a,b,c,d,2*atand(tp),w2);
        r.rama2 = drivenBranch(a,b,c,d,2*atand(tm),w2);
    end

    function s = drivenBranch(a,b,c,d,t2,w2)
        x = (a*sind(t2) - c)/b;
        if abs(x) > 1 + 1e-8, error('No se puede determinar theta3.'); end
        x = max(-1,min(1,x));
        tc = asind(x); to = 180 - asind(x);
        d1 = a*cosd(t2) - b*cosd(tc);
        d2 = a*cosd(t2) - b*cosd(to);
        if abs(d1-d) <= abs(d2-d)
            t3 = tc; s.circuito = 'cruzado'; s.dcheck = d1;
        else
            t3 = to; s.circuito = 'abierto'; s.dcheck = d2;
        end
        s.theta2 = t2; s.theta3 = t3;
        s.mu = acuteAngle(t3 - 90);
        if abs(cosd(t3)) < 1e-9
            s.w3 = NaN;
        else
            s.w3 = a*w2*cosd(t2)/(b*cosd(t3));
        end
        s.w2 = w2;
        s.VA = [-a*w2*sind(t2), a*w2*cosd(t2)];
    end

%% ---------------- MANIVELA-CORREDERA INVERTIDO ----------------

    function r = solveInverted(a,c,d,t2,gam,w2)
        P = a*sind(t2)*sind(gam) + (a*cosd(t2)-d)*cosd(gam);
        Q = -a*sind(t2)*cosd(gam) + (a*cosd(t2)-d)*sind(gam);
        R = -c*sind(gam);
        S = R - Q; T = 2*P; U = Q + R;
        disc = T^2 - 4*S*U;
        if disc < -1e-9, error('El mecanismo no cierra en ese angulo.'); end
        disc = max(disc,0);
        if abs(S) < 1e-12
            if abs(T) < 1e-12, error('La ecuacion de cierre degenera.'); end
            thm = 2*atand(-U/T); thp = thm;
        else
            thm = 2*atand((-T - sqrt(disc))/(2*S));
            thp = 2*atand((-T + sqrt(disc))/(2*S));
        end
        r.minus = invertedBranch(a,c,d,t2,gam,thm,w2);
        r.plus  = invertedBranch(a,c,d,t2,gam,thp,w2);
    end

    function s = invertedBranch(a,c,d,t2,gam,t4,w2)
        t3t = t4 + gam;
        numY = a*sind(t2) - c*sind(t4);
        if abs(sind(t3t)) > 1e-10
            bs = numY/sind(t3t);
        else
            numX = a*cosd(t2) - c*cosd(t4) - d;
            if abs(cosd(t3t)) < 1e-10, error('No se puede calcular b.'); end
            bs = numX/cosd(t3t);
        end
        if bs >= 0
            s.config = 'abierta'; t3 = t3t;      s.b = bs;
        else
            s.config = 'cruzada'; t3 = t3t - 180; s.b = abs(bs);
        end
        s.theta4 = t4; s.theta3 = t3; s.mu = abs(gam);
        if s.b > 1e-6
            s.w3 = a*w2*sind(t2-t4)/s.b;
        else
            s.w3 = NaN;
        end
        if abs(sind(t4-t3)) > 1e-9
            s.w4 = a*w2*sind(t2-t3)/(c*sind(t4-t3));
        else
            s.w4 = NaN;
        end
    end

%% ====================================================================
%% ============================ TABLAS ================================
%% ====================================================================

    function fillTables(r,m,a,b,c,d,gam)
        switch m
            case {1,2}
                o = r.open; x = r.cross;
                posTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                posTable.Data = { ...
                    'theta3', fmt(norm360(o.theta3)), fmt(norm360(x.theta3)), 'grados'; ...
                    'theta4', fmt(norm360(o.theta4)), fmt(norm360(x.theta4)), 'grados'; ...
                    'A  (x)', fmt(o.A(1)), fmt(x.A(1)), 'mm'; ...
                    'A  (y)', fmt(o.A(2)), fmt(x.A(2)), 'mm'; ...
                    'B  (x)', fmt(o.B(1)), fmt(x.B(1)), 'mm'; ...
                    'B  (y)', fmt(o.B(2)), fmt(x.B(2)), 'mm'; ...
                    'P  (x)', fmt(o.P(1)), fmt(x.P(1)), 'mm'; ...
                    'P  (y)', fmt(o.P(2)), fmt(x.P(2)), 'mm'; ...
                    'mu',     fmt(o.mu),   fmt(x.mu),   'grados'};

                velTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                velTable.Data = { ...
                    'omega2', fmt(fields.w2.Value), fmt(fields.w2.Value), 'rad/s'; ...
                    'omega3', fmt(o.w3), fmt(x.w3), 'rad/s'; ...
                    'omega4', fmt(o.w4), fmt(x.w4), 'rad/s'; ...
                    'V_A (x)',fmt(o.VA(1)), fmt(x.VA(1)), 'mm/s'; ...
                    'V_A (y)',fmt(o.VA(2)), fmt(x.VA(2)), 'mm/s'; ...
                    '|V_A|',  fmt(norm(o.VA)), fmt(norm(x.VA)), 'mm/s'; ...
                    'V_B (x)',fmt(o.VB(1)), fmt(x.VB(1)), 'mm/s'; ...
                    'V_B (y)',fmt(o.VB(2)), fmt(x.VB(2)), 'mm/s'; ...
                    '|V_B|',  fmt(norm(o.VB)), fmt(norm(x.VB)), 'mm/s'; ...
                    'V_P (x)',fmt(o.VP(1)), fmt(x.VP(1)), 'mm/s'; ...
                    'V_P (y)',fmt(o.VP(2)), fmt(x.VP(2)), 'mm/s'; ...
                    '|V_P|',  fmt(norm(o.VP)), fmt(norm(x.VP)), 'mm/s'};

                accTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                accTable.Data = { ...
                    'alpha2', fmt(fields.al2.Value), fmt(fields.al2.Value), 'rad/s^2'; ...
                    'alpha3', fmt(o.al3), fmt(x.al3), 'rad/s^2'; ...
                    'alpha4', fmt(o.al4), fmt(x.al4), 'rad/s^2'; ...
                    'A_A (x)',fmt(o.AA(1)), fmt(x.AA(1)), 'mm/s^2'; ...
                    'A_A (y)',fmt(o.AA(2)), fmt(x.AA(2)), 'mm/s^2'; ...
                    '|A_A|',  fmt(norm(o.AA)), fmt(norm(x.AA)), 'mm/s^2'; ...
                    'A_B (x)',fmt(o.AB(1)), fmt(x.AB(1)), 'mm/s^2'; ...
                    'A_B (y)',fmt(o.AB(2)), fmt(x.AB(2)), 'mm/s^2'; ...
                    '|A_B|',  fmt(norm(o.AB)), fmt(norm(x.AB)), 'mm/s^2'; ...
                    'A_P (x)',fmt(o.AP(1)), fmt(x.AP(1)), 'mm/s^2'; ...
                    'A_P (y)',fmt(o.AP(2)), fmt(x.AP(2)), 'mm/s^2'; ...
                    '|A_P|',  fmt(norm(o.AP)), fmt(norm(x.AP)), 'mm/s^2'};

            case 3
                o = r.open; x = r.cross;
                posTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                posTable.Data = { ...
                    'theta3', fmt(norm360(o.theta3)), fmt(norm360(x.theta3)), 'grados'; ...
                    'A  (x)', fmt(r.A(1)), fmt(r.A(1)), 'mm'; ...
                    'A  (y)', fmt(r.A(2)), fmt(r.A(2)), 'mm'; ...
                    'd',      fmt(o.d),  fmt(x.d),  'mm'; ...
                    'mu',     fmt(o.mu), fmt(x.mu), 'grados'};
                velTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                velTable.Data = { ...
                    'omega2', fmt(fields.w2.Value), fmt(fields.w2.Value), 'rad/s'; ...
                    'omega3', fmt(o.w3), fmt(x.w3), 'rad/s'; ...
                    '|V_A|',  fmt(norm(o.VA)), fmt(norm(x.VA)), 'mm/s'; ...
                    'v corredera', fmt(o.vb), fmt(x.vb), 'mm/s'};
                accTable.ColumnName = {'Variable','Abierta','Cruzada','Unidad'};
                accTable.Data = { ...
                    'alpha2', fmt(fields.al2.Value), fmt(fields.al2.Value), 'rad/s^2'; ...
                    'alpha3', fmt(o.al3), fmt(x.al3), 'rad/s^2'; ...
                    '|A_A|',  fmt(norm(o.AA)), fmt(norm(x.AA)), 'mm/s^2'; ...
                    'a corredera', fmt(o.ab), fmt(x.ab), 'mm/s^2'};

            case 4
                o = r.rama1; x = r.rama2;
                posTable.ColumnName = {'Variable','Rama 1','Rama 2','Unidad'};
                posTable.Data = { ...
                    'theta2', fmt(norm360(o.theta2)), fmt(norm360(x.theta2)), 'grados'; ...
                    'theta3', fmt(norm360(o.theta3)), fmt(norm360(x.theta3)), 'grados'; ...
                    'Circuito', o.circuito, x.circuito, '-'; ...
                    'd (comprob.)', fmt(o.dcheck), fmt(x.dcheck), 'mm'; ...
                    'mu', fmt(o.mu), fmt(x.mu), 'grados'};
                velTable.ColumnName = {'Variable','Rama 1','Rama 2','Unidad'};
                velTable.Data = { ...
                    'omega2', fmt(o.w2), fmt(x.w2), 'rad/s'; ...
                    'omega3', fmt(o.w3), fmt(x.w3), 'rad/s'; ...
                    '|V_A|',  fmt(norm(o.VA)), fmt(norm(x.VA)), 'mm/s'};
                accTable.ColumnName = {'Variable','Rama 1','Rama 2','Unidad'};
                accTable.Data = { ...
                    'Aceleracion', 'no disponible', 'no disponible', '-'; ...
                    'Motivo', 'la entrada es la posicion d', 'de la corredera', '-'};

            case 5
                o = r.minus; x = r.plus;
                posTable.ColumnName = {'Variable','Raiz (-)','Raiz (+)','Unidad'};
                posTable.Data = { ...
                    'theta3', fmt(norm360(o.theta3)), fmt(norm360(x.theta3)), 'grados'; ...
                    'theta4', fmt(norm360(o.theta4)), fmt(norm360(x.theta4)), 'grados'; ...
                    'b efectivo', fmt(o.b), fmt(x.b), 'mm'; ...
                    'Config', o.config, x.config, '-'; ...
                    'mu = gamma', fmt(abs(gam)), fmt(abs(gam)), 'grados'};
                velTable.ColumnName = {'Variable','Raiz (-)','Raiz (+)','Unidad'};
                velTable.Data = { ...
                    'omega2', fmt(fields.w2.Value), fmt(fields.w2.Value), 'rad/s'; ...
                    'omega3', fmt(o.w3), fmt(x.w3), 'rad/s'; ...
                    'omega4', fmt(o.w4), fmt(x.w4), 'rad/s'};
                accTable.ColumnName = {'Variable','Raiz (-)','Raiz (+)','Unidad'};
                accTable.Data = { ...
                    'Aceleracion', 'no disponible', 'no disponible', '-'; ...
                    'Motivo', 'la longitud b es variable', 'en esta inversion', '-'};
        end

        fillGrashof(m,a,b,c,d);
    end

    function fillGrashof(m,a,b,c,d)
        graTable.ColumnName = {'Parametro','Valor','Unidad'};
        graTable.ColumnWidth = {135,170,'auto'};
        if ~any(m == [1 2])
            graTable.Data = {'Grashof','solo aplica al cuatro barras','-'};
            grashofLbl.Text  = 'No aplica';
            grashofLbl.FontColor = muted;
            grashofTipo.Text = 'El criterio de Grashof es para el cuatro barras.';
            grashofSums.Text = '';
            return
        end
        [cls,tipo,S,L,PQ,estado,desc,rel] = grashofInfo(a,b,c,d);
        graTable.Data = { ...
            'S (mas corto)', fmt(S),   'mm'; ...
            'L (mas largo)', fmt(L),   'mm'; ...
            'P + Q',         fmt(PQ),  'mm'; ...
            'S + L',         fmt(S+L), 'mm'; ...
            'Condicion',     rel,      '-' ; ...
            'Clase',         cls,      '-' ; ...
            'Tipo',          tipo,     '-' };
        grashofLbl.Text  = cls;
        grashofTipo.Text = [tipo ': ' desc];
        grashofSums.Text = sprintf('S+L = %s      P+Q = %s', fmt(S+L), fmt(PQ));
        switch estado
            case 1, grashofLbl.FontColor = green;
            case 0, grashofLbl.FontColor = orange;
            case -1,grashofLbl.FontColor = red;
        end
    end

    function [cls,tipo,S,L,PQ,estado,desc,rel] = grashofInfo(a,b,c,d)
        v = sort([a b c d]);
        S = v(1); L = v(4); PQ = v(2) + v(3);
        tol = 1e-9*max(1,L);
        if S + L < PQ - tol
            cls = 'Grashof (Clase I)'; estado = 1; rel = 'S+L < P+Q';
            if abs(d-S) <= tol
                tipo = 'Doble manivela';
                desc = 'la bancada es el eslabon mas corto';
            elseif abs(b-S) <= tol
                tipo = 'Doble balancin';
                desc = 'el acoplador es el eslabon mas corto';
            else
                tipo = 'Manivela-balancin';
                desc = 'el eslabon mas corto da vuelta completa';
            end
        elseif S + L > PQ + tol
            cls = 'No Grashof (Clase II)'; estado = -1; rel = 'S+L > P+Q';
            tipo = 'Triple balancin';
            desc = 'ningun eslabon da vuelta completa';
        else
            cls = 'Punto de cambio (Clase III)'; estado = 0; rel = 'S+L = P+Q';
            tipo = 'Punto de cambio';
            desc = 'los eslabones llegan a alinearse (posicion singular)';
        end
    end

    function updateCards(r,m)
        switch m
            case {1,2}
                s = pickBranch(r,m);
                setCard(kpi.w3, s.w3);
                setCard(kpi.w4, s.w4);
                setCard(kpi.vp, norm(s.VP));
                setCard(kpi.ap, norm(s.AP));
                setGauge(s.mu);
            case 3
                s = pickBranch(r,m);
                setCard(kpi.w3, s.w3);
                setCard(kpi.w4, NaN);
                setCard(kpi.vp, s.vb);
                setCard(kpi.ap, s.ab);
                setGauge(s.mu);
            case 4
                s = pickBranch(r,m);
                setCard(kpi.w3, s.w3);
                setCard(kpi.w4, NaN);
                setCard(kpi.vp, norm(s.VA));
                setCard(kpi.ap, NaN);
                setGauge(s.mu);
            case 5
                s = pickBranch(r,m);
                setCard(kpi.w3, s.w3);
                setCard(kpi.w4, s.w4);
                setCard(kpi.vp, NaN);
                setCard(kpi.ap, NaN);
                setGauge(s.mu);
        end
    end

    function setGauge(mu)
        if isnan(mu), muGauge.Value = 0; else, muGauge.Value = max(0,min(90,mu)); end
    end

    function s = pickBranch(r,m)
        v = branchDD.Value;
        switch m
            case {1,2,3}
                if strcmp(v,'Cruzada'), s = r.cross; else, s = r.open; end
            case 4
                if strcmp(v,'Rama 2'), s = r.rama2; else, s = r.rama1; end
            case 5
                if strcmp(v,'Raiz (+)'), s = r.plus; else, s = r.minus; end
        end
    end

%% ====================================================================
%% ============================ DIBUJO ================================
%% ====================================================================

    function drawScene(r,m,a,c,d,t2)
        cla(ax); hold(ax,'on');
        both = strcmp(branchDD.Value,'Ambas');

        switch m
            case {1,2}
                if ~isempty(couplerPts) && curveChk.Value
                    plot(ax,couplerPts(:,1),couplerPts(:,2),':','LineWidth',1.4, ...
                        'Color',dimC(colP,0.75));
                end
                plot(ax,[0 d],[0 0],'-','LineWidth',5,'Color',colGround);
                if both
                    drawFourBar(r.cross,d,'--',0.45);
                    drawFourBar(r.open, d,'-', 1.0);
                else
                    drawFourBar(pickBranch(r,m),d,'-',1.0);
                end
                ttl = 'Cuatro barras';
            case 3
                if both
                    drawSlider(r.cross,a,c,t2,'--',0.45);
                    drawSlider(r.open, a,c,t2,'-', 1.0);
                else
                    drawSlider(pickBranch(r,m),a,c,t2,'-',1.0);
                end
                ttl = 'Manivela-corredera';
            case 4
                if both
                    drawDriven(r.rama2,a,c,d,'--',0.45);
                    drawDriven(r.rama1,a,c,d,'-', 1.0);
                else
                    drawDriven(pickBranch(r,m),a,c,d,'-',1.0);
                end
                ttl = 'Corredera-manivela';
            case 5
                plot(ax,[0 d],[0 0],'-','LineWidth',5,'Color',colGround);
                if both
                    drawInverted(r.plus, a,c,d,t2,'--',0.45);
                    drawInverted(r.minus,a,c,d,t2,'-', 1.0);
                else
                    drawInverted(pickBranch(r,m),a,c,d,t2,'-',1.0);
                end
                ttl = 'Manivela-corredera invertido';
        end

        title(ax,ttl,'FontWeight','bold');
        applyBounds();
        hold(ax,'off');
    end

    function drawFourBar(s,d,ls,alpha)
        A = s.A; B = s.B;
        plot(ax,[0 A(1)],[0 A(2)],ls,'LineWidth',3.5,'Color',dimC(colLink2,alpha));
        plot(ax,[A(1) B(1)],[A(2) B(2)],ls,'LineWidth',3.5,'Color',dimC(colLink3,alpha));
        plot(ax,[d B(1)],[0 B(2)],ls,'LineWidth',3.5,'Color',dimC(colLink4,alpha));
        if alpha > 0.9
            P = s.P;
            plot(ax,[A(1) P(1)],[A(2) P(2)],'-','LineWidth',1.6,'Color',dimC(colP,0.8));
            plot(ax,[B(1) P(1)],[B(2) P(2)],'-','LineWidth',1.6,'Color',dimC(colP,0.8));
            plot(ax,P(1),P(2),'o','MarkerSize',9,'MarkerFaceColor',colP, ...
                'MarkerEdgeColor','none');
            label(P,'  P',colP);
            if vecChk.Value
                sc = vecScale(s);
                drawVec(A,s.VA*sc,cyan);
                drawVec(B,s.VB*sc,cyan);
                drawVec(P,s.VP*sc,colP);
            end
        end
        pivots([0 0; d 0]);
        joints([A; B]);
        if alpha > 0.9
            label([0 0],'  O2',muted); label([d 0],'  O4',muted);
            label(A,'  A',txtCol);     label(B,'  B',txtCol);
        end
    end

    function drawSlider(s,a,c,t2,ls,alpha)
        A = [a*cosd(t2) a*sind(t2)]; B = s.B;
        xr = sort([0 B(1)]);
        pad = 0.35*max(a,1);
        plot(ax,[xr(1)-pad xr(2)+pad],[c c],':','LineWidth',1.5,'Color',colGround);
        plot(ax,[0 A(1)],[0 A(2)],ls,'LineWidth',3.5,'Color',dimC(colLink2,alpha));
        plot(ax,[A(1) B(1)],[A(2) B(2)],ls,'LineWidth',3.5,'Color',dimC(colLink3,alpha));
        w = 0.22*a;
        rectangle(ax,'Position',[B(1)-w/2, B(2)-w/2, w, w],'Curvature',0.2, ...
            'FaceColor',colLink4,'EdgeColor','none');
        pivots([0 0]); joints(A);
        if alpha > 0.9
            label([0 0],'  O2',muted); label(A,'  A',txtCol); label(B,'  B',txtCol);
        end
    end

    function drawDriven(s,a,c,d,ls,alpha)
        A = [a*cosd(s.theta2) a*sind(s.theta2)]; B = [d c];
        xr = sort([0 d]); pad = 0.35*max(a,1);
        plot(ax,[xr(1)-pad xr(2)+pad],[c c],':','LineWidth',1.5,'Color',colGround);
        plot(ax,[0 A(1)],[0 A(2)],ls,'LineWidth',3.5,'Color',dimC(colLink2,alpha));
        plot(ax,[A(1) B(1)],[A(2) B(2)],ls,'LineWidth',3.5,'Color',dimC(colLink3,alpha));
        w = 0.22*a;
        rectangle(ax,'Position',[B(1)-w/2, B(2)-w/2, w, w],'Curvature',0.2, ...
            'FaceColor',colLink4,'EdgeColor','none');
        pivots([0 0]); joints(A);
        if alpha > 0.9
            label([0 0],'  O2',muted); label(A,'  A',txtCol); label(B,'  B',txtCol);
        end
    end

    function drawInverted(s,a,c,d,t2,ls,alpha)
        A = [a*cosd(t2) a*sind(t2)];
        B = [d + c*cosd(s.theta4), c*sind(s.theta4)];
        plot(ax,[0 A(1)],[0 A(2)],ls,'LineWidth',3.5,'Color',dimC(colLink2,alpha));
        plot(ax,[d B(1)],[0 B(2)],ls,'LineWidth',3.5,'Color',dimC(colLink4,alpha));
        plot(ax,[B(1) A(1)],[B(2) A(2)],ls,'LineWidth',3.5,'Color',dimC(colLink3,alpha));
        pivots([0 0; d 0]); joints([A; B]);
        if alpha > 0.9
            label([0 0],'  O2',muted); label([d 0],'  O4',muted);
            label(A,'  A',txtCol);     label(B,'  B',txtCol);
        end
    end

    function pivots(pts)
        for i = 1:size(pts,1)
            plot(ax,pts(i,1),pts(i,2),'^','MarkerSize',11, ...
                'MarkerFaceColor',colGround,'MarkerEdgeColor',muted,'LineWidth',1);
        end
    end

    function joints(pts)
        for i = 1:size(pts,1)
            plot(ax,pts(i,1),pts(i,2),'o','MarkerSize',8, ...
                'MarkerFaceColor',[0.10 0.13 0.20],'MarkerEdgeColor',white,'LineWidth',1.4);
        end
    end

    function label(p,txt,col)
        text(ax,p(1),p(2),txt,'Color',col,'FontWeight','bold','FontSize',10, ...
            'VerticalAlignment','bottom');
    end

    function drawVec(p,v,col)
        if any(~isfinite(v)), return; end
        quiver(ax,p(1),p(2),v(1),v(2),0,'Color',col,'LineWidth',1.8, ...
            'MaxHeadSize',0.6);
    end

    function sc = vecScale(s)
        % La flecha mas larga ocupa el 18% del ancho visible, asi ningun
        % vector se sale del grafico por rapido que vaya el mecanismo.
        if isempty(axBounds), sc = 1; return; end
        span = max(axBounds(2)-axBounds(1), axBounds(4)-axBounds(3));
        vmax = max([norm(s.VA), norm(s.VB), norm(s.VP)]);
        if ~isfinite(vmax) || vmax < eps, sc = 0; return; end
        sc = 0.18*span/vmax;
    end

    function applyBounds()
        axis(ax,'equal');
        if ~isempty(axBounds) && all(isfinite(axBounds))
            xlim(ax,axBounds(1:2)); ylim(ax,axBounds(3:4));
        else
            axis(ax,'tight');
        end
    end

%% ---------------- LIMITES Y CURVA DEL ACOPLADOR ----------------

    function bb = computeBounds(m,a,b,c,d,rpa,phi,gam,w2,al2)
        pts = [0 0; d 0];
        if m == 4
            bb = []; return
        end
        for ang = 0:6:354
            try
                switch m
                    case 1, rr = solveFourBarCoords(a,b,c,d,ang,w2,al2,rpa,phi);
                    case 2, rr = solveFourBarLoop(a,b,c,d,ang,w2,al2,rpa,phi);
                    case 3, rr = solveSliderCrank(a,b,c,ang,w2,al2);
                    case 5, rr = solveInverted(a,c,d,ang,gam,w2);
                end
            catch
                continue
            end
            switch m
                case {1,2}
                    pts = [pts; rr.open.A; rr.open.B; rr.open.P; ...
                                rr.cross.A; rr.cross.B; rr.cross.P]; %#ok<AGROW>
                case 3
                    pts = [pts; rr.A; rr.open.B; rr.cross.B]; %#ok<AGROW>
                case 5
                    B1 = [d + c*cosd(rr.minus.theta4), c*sind(rr.minus.theta4)];
                    B2 = [d + c*cosd(rr.plus.theta4),  c*sind(rr.plus.theta4)];
                    pts = [pts; a*cosd(ang) a*sind(ang); B1; B2]; %#ok<AGROW>
            end
        end
        pts = pts(all(isfinite(pts),2),:);
        if isempty(pts), bb = []; return; end
        xr = [min(pts(:,1)) max(pts(:,1))];
        yr = [min(pts(:,2)) max(pts(:,2))];
        pad = 0.12*max([diff(xr), diff(yr), 1]);
        bb = [xr(1)-pad, xr(2)+pad, yr(1)-pad, yr(2)+pad];
    end

    function pts = couplerCurve(a,b,c,d,rpa,phi,w2,al2)
        m = currentMethod();
        cross = strcmp(branchDD.Value,'Cruzada');
        angs = 0:2:360;
        pts = nan(numel(angs),2);
        for i = 1:numel(angs)
            try
                if m == 1
                    rr = solveFourBarCoords(a,b,c,d,angs(i),w2,al2,rpa,phi);
                else
                    rr = solveFourBarLoop(a,b,c,d,angs(i),w2,al2,rpa,phi);
                end
                if cross, pts(i,:) = rr.cross.P; else, pts(i,:) = rr.open.P; end
            catch
                pts(i,:) = [NaN NaN];
            end
        end
    end

%% ====================================================================
%% =========================== ANIMACION ==============================
%% ====================================================================

    function animate()
        if animating, return; end
        if currentMethod() == 4
            uialert(fig,'Este mecanismo se controla con la posicion d, no con theta2.', ...
                'No se puede animar','Icon','info');
            return
        end
        animating = true;
        animBtn.Enable = 'off'; stopBtn.Enable = 'on';
        old = fields.t2.Value;
        switch speedDD.Value
            case 'Lento',  step = 1.5;
            case 'Rapido', step = 6;
            otherwise,     step = 3;
        end
        ang = old;
        while animating && isvalid(fig)
            ang = mod(ang + step, 360);
            fields.t2.Value = ang;
            t2Slider.Value  = ang;
            quickCalc();
            drawnow limitrate
        end
        if isvalid(fig)
            fields.t2.Value = old; t2Slider.Value = old;
            animBtn.Enable = 'on'; stopBtn.Enable = 'off';
            fullCalc();
        end
    end

    function stopAnim()
        animating = false;
    end

%% ====================================================================
%% =========================== EXPORTAR ===============================
%% ====================================================================

    function exportResults(destOverride)
        if isempty(fieldnames(lastResult))
            uialert(fig,'Primero calcula un mecanismo.','Nada que exportar','Icon','warning');
            return
        end
        if nargin >= 1 && ~isempty(destOverride)
            dest = destOverride;
            [~,fn,ex] = fileparts(dest); f = [fn ex];
            silent = true;
        else
            [f,p] = uiputfile({'*.xlsx','Libro de Excel (*.xlsx)'}, ...
                'Guardar resultados','Resultados_Mecanismo.xlsx');
            if isequal(f,0), return; end
            dest = fullfile(p,f);
            silent = false;
        end
        try
            C = buildExportCell();
            if exist('writecell','file')
                writecell(C,dest);
            else
                xlswrite(dest,C);
            end
            statusLbl.Text = ['Resultados guardados en ' f];
            statusLbl.FontColor = green;
            if ~silent
                uialert(fig,sprintf('Archivo guardado:\n%s',dest), ...
                    'Exportacion completada','Icon','success');
            end
        catch ME
            if silent, rethrow(ME); end
            uialert(fig,ME.message,'No se pudo guardar','Icon','error');
        end
    end

    function C = buildExportCell()
        C = {};
        C(end+1,1:4) = {'CALCULADORA DE MECANISMOS','','',''};
        C(end+1,1:4) = {'Mecanismo',methodDD.Value,'',''};
        C(end+1,1:4) = {'Solucion mostrada',branchDD.Value,'',''};
        C(end+1,1:4) = {'Generado',char(datetime('now','Format','dd/MM/yyyy HH:mm')),'',''};
        C(end+1,1:4) = {'','','',''};

        C(end+1,1:4) = {'DATOS DE ENTRADA','','',''};
        C(end+1,1:4) = {'Parametro','Valor','Unidad',''};
        units = {'mm','mm','mm','mm','grados','rad/s','rad/s^2','grados','mm','grados'};
        for kk = 1:numel(fieldNames)
            nm = fieldNames{kk};
            if strcmp(fields.(nm).Visible,'on')
                C(end+1,1:4) = {baseLabels{kk}, fields.(nm).Value, units{kk}, ''}; %#ok<AGROW>
            end
        end
        C(end+1,1:4) = {'','','',''};

        C = appendTable(C,'POSICION',posTable);
        C = appendTable(C,'VELOCIDAD',velTable);
        C = appendTable(C,'ACELERACION',accTable);
        C = appendTable(C,'GRASHOF',graTable);
    end

    function C = appendTable(C,titleTxt,tbl)
        C(end+1,1:4) = {titleTxt,'','',''};
        cn = tbl.ColumnName(:).';
        row = {'','','',''};
        for j = 1:min(4,numel(cn)), row{j} = cn{j}; end
        C(end+1,1:4) = row;
        D = tbl.Data;
        for i = 1:size(D,1)
            row = {'','','',''};
            for j = 1:min(4,size(D,2)), row{j} = D{i,j}; end
            C(end+1,1:4) = row; %#ok<AGROW>
        end
        C(end+1,1:4) = {'','','',''};
    end

%% ====================================================================
%% =========================== UTILIDADES =============================
%% ====================================================================

    function col = dimC(base,alpha)
        % Mezcla el color con el fondo del eje: equivale a transparencia
        % pero funciona en cualquier version de MATLAB.
        col = base*alpha + ax.Color*(1-alpha);
    end

    function mu = acuteAngle(delta)
        v = mod(abs(delta),180);
        if v > 90, v = 180 - v; end
        mu = v;
    end

    function v = norm360(v)
        v = mod(v,360);
    end

    function s = fmt(x)
        if ischar(x) || isstring(x), s = char(x); return; end
        if isempty(x) || ~isfinite(x), s = '--'; return; end
        if abs(x) >= 1e5 || (abs(x) < 1e-3 && x ~= 0)
            s = sprintf('%.4e',x);
        else
            s = sprintf('%.4f',x);
        end
    end

    function setCard(h,val)
        h.Text = fmt(val);
    end

    function h = makeCard(parent,titleTxt,col)
        p = uipanel(parent,'BackgroundColor',panel,'BorderType','none');
        g = uigridlayout(p,[2 1]);
        g.RowHeight = {15,'1x'};
        g.Padding = [10 4 8 4]; g.RowSpacing = 0;
        g.BackgroundColor = panel;
        t = uilabel(g,'Text',titleTxt,'FontSize',9,'FontColor',muted);
        t.Layout.Row = 1;
        h = uilabel(g,'Text','--','FontSize',19,'FontWeight','bold','FontColor',col);
        h.Layout.Row = 2;
    end

    function t = makeTable(parent,tag,bgc,bgc2,fgc)
        g = uigridlayout(parent,[1 1]);
        g.Padding = [6 6 6 6];
        g.BackgroundColor = bgc;
        t = uitable(g,'Data',cell(0,4), ...
            'ColumnName',{'Variable','Abierta','Cruzada','Unidad'}, ...
            'RowName',[],'Tag',tag, ...
            'BackgroundColor',[bgc; bgc2],'ForegroundColor',fgc, ...
            'FontName','Consolas','FontSize',11);
        t.ColumnWidth = {110,105,105,'auto'};
    end

    function mkCap(parent,txt,rowIdx,colIdx,col)
        l = uilabel(parent,'Text',txt,'FontSize',9,'FontColor',col,'FontWeight','bold');
        l.Layout.Row = rowIdx; l.Layout.Column = colIdx;
    end

end



