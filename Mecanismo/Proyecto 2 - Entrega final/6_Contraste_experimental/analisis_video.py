"""
Inciso g) - Contraste experimental del dosificador (manivela-corredera)
Analisis cuadro por cuadro del video del modelo funcionando.

Que hace:
  1. Extrae los cuadros del video (ffmpeg).
  2. En cada cuadro de la vista lateral detecta el disco de la manivela (Hough) y localiza
     los pasadores A y B por correlacion con una plantilla (precision subpixel).
  3. Mide todo respecto del centro del disco del mismo cuadro (elimina el movimiento de la
     camara) y usa el diametro del disco (90 mm) como escala en cada cuadro.
  4. Corrige el giro de la camara, la perspectiva y el centro de giro en el plano de los pasadores.
  5. Calcula omega2 por vuelta, la posicion y la velocidad del bloque y las compara con la teoria.
  6. Analiza los datos de Tracker del grupo (tracker_masa_A.csv): ajuste circular con giro uniforme.
  7. Guarda resultados_g.json, medicion_video.csv, theta2_video.csv y las figuras g1 a g4 (carpeta 4_Figuras).

Uso:  python analisis_video.py video_modelo_funcionando.mp4
Requiere: ffmpeg, numpy, opencv-python, matplotlib
"""
import os, sys, json, glob, subprocess, tempfile
import numpy as np, cv2, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

AQUI = os.path.dirname(os.path.abspath(__file__))
VIDEO = sys.argv[1] if len(sys.argv) > 1 else os.path.join(AQUI, 'video_modelo_funcionando.mp4')
FIG = os.path.join(AQUI, '..', '4_Figuras')
CUADROS = os.path.join(tempfile.gettempdir(), 'cuadros_dosificador')   # fuera de la carpeta del proyecto
FPS = 30.0
N_LATERAL = 172                 # cuadros con vista lateral (las primeras 4 vueltas)
D_DISCO = 90.0                  # diametro del disco de la manivela [mm] (modelo de Inventor)
a, b, c = 35.0, 132.0, -20.0    # medidas de diseno = planos de las piezas (5_Inventor/Dimensiones_de_piezas.pdf) [mm]
A0, B0, O0 = (376, 396), (559, 375), (348.6, 349.4, 61.0)   # posiciones iniciales en el cuadro 1 [px]

# ---------------------------------------------------------------- 1. cuadros
os.makedirs(CUADROS, exist_ok=True)
if not glob.glob(os.path.join(CUADROS, 'f_*.png')):
    subprocess.run(['ffmpeg', '-v', 'error', '-i', VIDEO, '-vsync', '0', os.path.join(CUADROS, 'f_%03d.png')], check=True)
gris = lambda i: cv2.cvtColor(cv2.imread(os.path.join(CUADROS, f'f_{i:03d}.png')), cv2.COLOR_BGR2GRAY).astype(np.float32)

def buscar(g, T, pred, win):
    """Correlacion normalizada de la plantilla T alrededor de pred, con refinamiento subpixel."""
    h = T.shape[0] // 2
    x0 = int(np.clip(round(pred[0]), win + h + 1, g.shape[1] - win - h - 2))
    y0 = int(np.clip(round(pred[1]), win + h + 1, g.shape[0] - win - h - 2))
    r = cv2.matchTemplate(g[y0 - win - h:y0 + win + h + 1, x0 - win - h:x0 + win + h + 1], T, cv2.TM_CCOEFF_NORMED)
    _, mx, _, (lx, ly) = cv2.minMaxLoc(r)
    sp = lambda p, q, s: 0.0 if (p - 2 * q + s) == 0 else 0.5 * (p - s) / (p - 2 * q + s)
    dx = sp(r[ly, lx - 1], r[ly, lx], r[ly, lx + 1]) if 0 < lx < r.shape[1] - 1 else 0
    dy = sp(r[ly - 1, lx], r[ly, lx], r[ly + 1, lx]) if 0 < ly < r.shape[0] - 1 else 0
    return np.array([x0 - win + lx + dx, y0 - win + ly + dy]), mx

def disco(g, prev):
    x0, y0, m = int(prev[0]), int(prev[1]), 95
    roi = cv2.GaussianBlur(g[y0 - m:y0 + m, x0 - m:x0 + m].astype(np.uint8), (7, 7), 2)
    cs = cv2.HoughCircles(roi, cv2.HOUGH_GRADIENT, dp=1.2, minDist=300, param1=60, param2=22, minRadius=50, maxRadius=78)
    if cs is None: return None
    cc = cs[0][0]; return np.array([x0 - m + cc[0], y0 - m + cc[1], cc[2]])

# ---------------------------------------------------------------- 2. seguimiento de O2 (disco) y A
g1 = gris(1)
TA = g1[A0[1] - 11:A0[1] + 12, A0[0] - 11:A0[0] + 12].copy()
TB = g1[B0[1] - 9:B0[1] + 10, B0[0] - 9:B0[0] + 10].copy()
O = np.array(O0); pA = np.array(A0, float); vA_ = np.zeros(2)
Os, As, Rs = [], [], []
for i in range(1, N_LATERAL + 1):
    g = gris(i)
    o = disco(g, O)
    if o is not None and np.hypot(*(o[:2] - O[:2])) < 15: O = o
    pa, _ = buscar(g, TA, pA + vA_, 22)
    vA_ = 0.7 * (pa - pA) if i > 1 else vA_; pA = pa
    Os.append(O[:2].copy()); Rs.append(O[2]); As.append(pa)
Os, As, Rs = np.array(Os), np.array(As), np.array(Rs)
Rsm = np.convolve(np.pad(Rs, (4, 4), mode='edge'), np.ones(9) / 9, mode='valid')   # escala suavizada

# ---------------------------------------------------------------- 3. pasador B (prediccion geometrica + correlacion)
L1 = np.hypot(B0[0] - A0[0], B0[1] - A0[1]); off1 = B0[1] - Os[0, 1]
Bs, okB = [], []
for k in range(N_LATERAL):
    g = gris(k + 1); s_ = Rsm[k] / Rsm[0]
    by = Os[k, 1] + off1 * s_; bx = As[k, 0] + np.sqrt(max((L1 * s_) ** 2 - (As[k, 1] - by) ** 2, 0))
    pb, cb = buscar(g, TB, (bx, by), 10)
    ia, ja = int(pb[1]), int(pb[0])
    contraste = g[ia - 8:ia + 9, ja - 8:ja + 9].mean() - g[ia - 2:ia + 3, ja - 2:ja + 3].mean()   # agujero oscuro
    Bs.append(pb); okB.append(cb > 0.8 and contraste > 40)
Bs, ok = np.array(Bs), np.array(okB)

# ---------------------------------------------------------------- 4. a mm, correcciones
t = np.arange(N_LATERAL) / FPS
esc = (D_DISCO / 2) / Rsm
vA = (As - Os) * esc[:, None]; vA[:, 1] *= -1
vB = (Bs - Os) * esc[:, None]; vB[:, 1] *= -1
pb_ = np.polyfit(vB[ok, 0], vB[ok, 1], 1); roll = np.arctan(pb_[0])                 # giro de la camara
Rm = np.array([[np.cos(roll), np.sin(roll)], [-np.sin(roll), np.cos(roll)]]); vA = vA @ Rm.T; vB = vB @ Rm.T
co, *_ = np.linalg.lstsq(np.c_[vA[:, 0] ** 2, vA[:, 1] ** 2], np.ones(len(vA)), rcond=None)
ky = np.sqrt(co[1]) / np.sqrt(co[0]); vA[:, 1] *= ky; vB[:, 1] *= ky                 # perspectiva
x, y = vA.T; (cx, cy, c0), *_ = np.linalg.lstsq(np.c_[2 * x, 2 * y, np.ones_like(x)], x ** 2 + y ** 2, rcond=None)
vA -= [cx, cy]; vB -= [cx, cy]                                                      # centro de giro real

# ---------------------------------------------------------------- 5. resultados
th = np.unwrap(np.arctan2(vA[:, 1], vA[:, 0])); rA = np.hypot(*vA.T)
pf = np.polyfit(t, th, 1); w2 = pf[0]; ph = np.polyval(pf, t)
crs = []
for k in range(1, 6):
    tg = th[0] + 2 * np.pi * k; idx = np.where((th[:-1] < tg) & (th[1:] >= tg))[0]
    if len(idx): j = idx[0]; crs.append(t[j] + (tg - th[j]) / (th[j + 1] - th[j]) * (t[j + 1] - t[j]))
T = np.diff([0] + crs); rpm = 60 / T; n = len(rpm); s = rpm.std(ddof=1)
tst = {1: 12.706, 2: 4.303, 3: 3.182, 4: 2.776, 5: 2.571}[n - 1]; U95 = tst * s / np.sqrt(n)
X = np.c_[np.ones_like(t), np.sin(ph), np.cos(ph), np.sin(2 * ph), np.cos(2 * ph)]; cf, *_ = np.linalg.lstsq(X, th - ph, rcond=None)
w_inst = w2 * (1 + cf[1] * np.cos(ph) - cf[2] * np.sin(ph) + 2 * cf[3] * np.cos(2 * ph) - 2 * cf[4] * np.sin(2 * ph))
th2 = np.degrees(th) % 360

def teoria(th2, w=w2):
    s_ = (a * np.sin(np.radians(th2)) - c) / b; t3 = 180 - np.degrees(np.arcsin(s_))
    d = a * np.cos(np.radians(th2)) - b * np.cos(np.radians(t3))
    w3 = a * w * np.cos(np.radians(th2)) / (b * np.cos(np.radians(t3)))
    return d, -a * w * np.sin(np.radians(th2)) + b * w3 * np.sin(np.radians(t3))

d_m = vB[ok, 0]; e = d_m - teoria(th2[ok])[0]
vB_m = np.full(N_LATERAL, np.nan)
for k in np.where(ok)[0]:
    w_ = [j for j in range(k - 3, k + 4) if 0 <= j < N_LATERAL and ok[j]]
    if len(w_) >= 5 and max(w_) - min(w_) == len(w_) - 1:
        vB_m[k] = np.polyfit(t[w_] - t[k], vB[w_, 0], 2)[1]
w_med = rpm.mean() * np.pi / 30            # omega2 promedio de las vueltas completas (mejor estimacion)
vv = ~np.isnan(vB_m); ev = vB_m[vv] - teoria(th2[vv], w_med)[1]
dmins = []
for k in range(len(crs) + 1):
    t0 = 0 if k == 0 else crs[k - 1]; t1 = crs[k] if k < len(crs) else t[-1]
    m = ok & (t >= t0) & (t < t1)
    if m.sum() > 10: dmins.append(vB[m, 0].min())
dd = teoria(th2[ok], 1.0)[1]; ret, av = dd < -15, dd > 15                               # dd/dtheta2 [mm/rad]
m1, m2 = vv & (np.abs(th2 - 69) < 12), vv & (np.abs(th2 - 276.5) < 12)
vpk = teoria(np.array([69.0, 276.5]), w_med)[1]
R = dict(w2=w2, rpm_global=w2 * 30 / np.pi, rpm=rpm.tolist(), T=T.tolist(), rpm_mean=rpm.mean(), rpm_s=s, rpm_U95=U95,
         rpm_cv=100 * s / rpm.mean(), t_student=tst, ratio=rpm.mean() / 30,
         fluct_amp1_deg=float(np.degrees(np.hypot(cf[1], cf[2]))), w_min=float(w_inst.min()), w_max=float(w_inst.max()),
         th_wmin=float(th2[w_inst.argmin()]), th_wmax=float(th2[w_inst.argmax()]),
         rA=rA.mean(), rA_s=rA.std(ddof=1), b=np.hypot(*(vB - vA)[ok].T).mean(), b_s=np.hypot(*(vB - vA)[ok].T).std(ddof=1),
         c=vB[ok, 1].mean(), c_s=vB[ok, 1].std(ddof=1), n_vis=int(ok.sum()), n=N_LATERAL,
         d_err_mean=e.mean(), d_err_rms=np.sqrt((e ** 2).mean()), d_err_max=abs(e).max(),
         dmin_meas=float(np.mean(dmins)), dmin_meas_s=float(np.std(dmins, ddof=1)), n_dmin=len(dmins),
         v_err_rms=float(np.sqrt(np.mean(ev ** 2))), vpk_ret_meas=float(np.nanmean(vB_m[m1])), vpk_av_meas=float(np.nanmean(vB_m[m2])),
         vpk_ret_teo=float(vpk[0]), vpk_av_teo=float(vpk[1]),
         lag_ret=float(e[ret].mean()), lag_av=float(e[av].mean()),
         center_shift=[float(cx), float(cy)], ky=float(ky), roll=float(np.degrees(roll)), dur=float(t[-1]))
# ---------------------------------------------------------------- 6. Tracker del grupo (masa_A)
Tk = np.genfromtxt(os.path.join(AQUI, 'tracker_masa_A.csv'), delimiter=',', names=True)
tx, xx, yy = Tk['t'], Tk['x'], Tk['y']
(tcx, tcy, tc0), *_ = np.linalg.lstsq(np.c_[2 * xx, 2 * yy, np.ones_like(xx)], xx ** 2 + yy ** 2, rcond=None)
tR = np.sqrt(tc0 + tcx ** 2 + tcy ** 2); tth = np.unwrap(np.arctan2(yy - tcy, xx - tcx)); tp = np.polyfit(tx, tth, 1)
R.update(trk_R=tR, trk_w=tp[0], trk_rpm=tp[0] * 30 / np.pi, trk_res_deg=float(np.degrees(tth - np.polyval(tp, tx)).std()),
         trk_n=len(tx), trk_dur=float(tx[-1] - tx[0]), trk_sweep=float(np.degrees(tth[-1] - tth[0])))

# ---------------------------------------------------------------- 7. archivos
json.dump(R, open(os.path.join(AQUI, 'resultados_g.json'), 'w'), indent=1)
with open(os.path.join(AQUI, 'medicion_video.csv'), 'w') as f:
    f.write('t,x,th2\n')
    for k in np.where(ok)[0]: f.write(f'{t[k]:.5f},{vB[k, 0]:.3f},{th2[k]:.3f}\n')
with open(os.path.join(AQUI, 'theta2_video.csv'), 'w') as f:
    f.write('cuadro,t_s,theta2_grados_desenrollado,radio_A_mm\n')
    for k in range(N_LATERAL): f.write(f'{k + 1},{t[k]:.5f},{np.degrees(th[k]):.3f},{rA[k]:.3f}\n')
for k_, v_ in R.items(): print(f'{k_:>16}: {np.round(v_, 4) if not isinstance(v_, list) else np.round(v_, 4)}')

# ---------------------------------------------------------------- 8. figuras
BLUE, ORANGE, GRAY, INK = '#2a78d6', '#eb6834', '#8a8a8a', '#222222'
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False})
thc = np.linspace(0, 360, 721); dc, vc = teoria(thc, w_med); _, vc30 = teoria(thc, np.pi)
# g1
fig, ax = plt.subplots(1, 2, figsize=(10.5, 3.8), gridspec_kw={'width_ratios': [1.5, 1]})
ax[0].plot(t, np.degrees(th - th[0]), 'o', ms=3, color=BLUE, label='Medido en el video (pasador A)')
ax[0].plot(t, np.degrees(ph - th[0]), '-', color=INK, lw=1.2, label=f'Ajuste lineal: ω₂ = {w2:.3f} rad/s')
ax[0].plot(t, np.degrees(np.pi * t), '--', color=ORANGE, lw=1.5, label='Diseño: 30 rpm (π rad/s)')
for tc in crs: ax[0].axvline(tc, color=GRAY, lw=0.6, ls=':')
ax[0].set_xlabel('t (s)'); ax[0].set_ylabel('giro de la manivela θ₂ − θ₂,0 (°)'); ax[0].legend(frameon=False, fontsize=8.5); ax[0].grid(alpha=0.25)
ax[0].set_title('Ángulo de la manivela en el video (30 cuadros/s)', fontsize=10, fontweight='bold')
kk = np.arange(1, n + 1); ax[1].bar(kk, rpm, color=BLUE, width=0.55)
ax[1].axhline(rpm.mean(), color=INK, lw=1.2); ax[1].axhline(30, color=ORANGE, ls='--', lw=1.5)
ax[1].text(n + 0.75, rpm.mean() + 0.8, f'media {rpm.mean():.1f}', va='bottom', fontsize=9)
ax[1].text(n + 0.75, 30.8, 'diseño 30', va='bottom', fontsize=9, color=ORANGE)
for k_, r_ in zip(kk, rpm): ax[1].text(k_, r_ + 0.6, f'{r_:.2f}', ha='center', fontsize=8.5)
ax[1].set_xticks(kk); ax[1].set_xlabel('vuelta'); ax[1].set_ylabel('n (rpm)'); ax[1].set_ylim(0, 52); ax[1].set_xlim(0.4, n + 2.1)
ax[1].set_title('Velocidad media en cada vuelta', fontsize=10, fontweight='bold')
fig.tight_layout(); fig.savefig(os.path.join(FIG, 'g1_velocidad_entrada.png'), dpi=200); plt.close(fig)
# g2
fig, ax = plt.subplots(1, 2, figsize=(10.5, 3.7)); tt = np.linspace(tx[0], tx[-1], 200); thf = np.polyval(tp, tt)
ax[0].plot(tx, xx, 's', ms=4, color=BLUE, label='x (Tracker)'); ax[0].plot(tx, yy, 'o', ms=4, color=ORANGE, label='y (Tracker)')
ax[0].plot(tt, tcx + tR * np.cos(thf), '-', color=BLUE, lw=1); ax[0].plot(tt, tcy + tR * np.sin(thf), '-', color=ORANGE, lw=1)
ax[0].set_xlabel('t (s)'); ax[0].set_ylabel('posición (unidades de Tracker)'); ax[0].legend(frameon=False, fontsize=8.5); ax[0].grid(alpha=0.25)
ax[0].set_title('masa_A: datos del grupo y ajuste circular', fontsize=10, fontweight='bold')
ax[1].set_aspect('equal'); ax[1].plot(xx, yy, 'o', ms=4, color=BLUE); aa = np.linspace(0, 2 * np.pi, 200)
ax[1].plot(tcx + tR * np.cos(aa), tcy + tR * np.sin(aa), '-', color=GRAY, lw=0.8); ax[1].plot([tcx], [tcy], '+', color=INK, ms=10)
ax[1].set_title(f'Trayectoria: circunferencia R = {tR:.1f}\nω₂ = {tp[0]:.2f} rad/s = {tp[0] * 30 / np.pi:.1f} rpm', fontsize=10, fontweight='bold')
ax[1].set_xlabel('x'); ax[1].set_ylabel('y'); ax[1].grid(alpha=0.25)
fig.tight_layout(); fig.savefig(os.path.join(FIG, 'g2_tracker_masaA.png'), dpi=200); plt.close(fig)
# g3
fig, ax = plt.subplots(2, 1, figsize=(9.5, 6.2), sharex=True, gridspec_kw={'height_ratios': [2.3, 1]})
ax[0].plot(thc, dc, '-', color=BLUE, lw=2, label='Teórico (a = 35, b = 132, c = −20 mm)')
ax[0].plot(th2[ok], d_m, 'o', ms=3.5, color=ORANGE, alpha=0.85, label=f'Medido en el video ({ok.sum()} cuadros)')
ax[0].axhline(R['dmin_meas'], color=GRAY, lw=1)
ax[0].text(232, R['dmin_meas'] + 0.8, f'd mín medido = {R["dmin_meas"]:.2f} mm (teórico 94.92)', fontsize=8.5, color=INK, va='bottom')
ax[0].text(347, 140, 'B dentro de\nla caja\n(no visible)', ha='center', fontsize=8, color=GRAY)
ax[0].set_ylabel('d (mm)'); ax[0].legend(frameon=False, fontsize=9, loc='upper center'); ax[0].grid(alpha=0.25)
ax[0].set_title('Posición del pasador B (bloque) en función de θ₂: modelo físico vs teoría', fontsize=10.5, fontweight='bold')
ax[1].axhline(0, color=INK, lw=0.8); ax[1].plot(th2[ok], e, 'o', ms=3, color=ORANGE); ax[1].set_ylabel('medido − teórico\n(mm)'); ax[1].grid(alpha=0.25)
ax[1].set_xlabel('θ₂ medido (°)'); ax[1].set_xlim(0, 360); ax[1].set_xticks(range(0, 361, 36))
ax[1].text(5, ax[1].get_ylim()[1] * 0.8, f'error medio {e.mean():+.2f} mm · RMS {R["d_err_rms"]:.2f} mm', fontsize=8.5)
fig.tight_layout(); fig.savefig(os.path.join(FIG, 'g3_posicion_bloque.png'), dpi=200); plt.close(fig)
# g4
fig, ax = plt.subplots(figsize=(9.5, 3.9))
ax.plot(thc, vc, '-', color=BLUE, lw=2, label=f'Teórico con ω₂ medida ({R["rpm_mean"]:.1f} rpm)')
ax.plot(thc, vc30, '--', color=GRAY, lw=1.3, label='Teórico con ω₂ de diseño (30 rpm)')
ax.plot(th2[vv], vB_m[vv], 'o', ms=3.5, color=ORANGE, label='Medido en el video (derivada numérica)')
ax.axhline(0, color=INK, lw=0.6); ax.set_xlim(0, 360); ax.set_xticks(range(0, 361, 36)); ax.set_xlabel('θ₂ medido (°)'); ax.set_ylabel('V_B (mm/s)')
ax.legend(frameon=False, fontsize=8.5, loc='lower right'); ax.grid(alpha=0.25)
ax.set_title('Velocidad del bloque: el modelo físico sigue la curva de la velocidad medida, no la de diseño', fontsize=10.5, fontweight='bold')
fig.tight_layout(); fig.savefig(os.path.join(FIG, 'g4_velocidad_bloque.png'), dpi=200); plt.close(fig)
print('figuras g1-g4 guardadas en', os.path.abspath(FIG))
