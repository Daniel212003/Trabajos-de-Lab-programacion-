// Libreria comun de las simulaciones del dosificador (manivela-corredera descentrada).
// Unidades: metros, segundos, radianes. Marco local del mecanismo: origen en O2, x hacia el bloque,
// y hacia arriba, z hacia el observador (lado de la biela).
import * as THREE from 'three';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import { Line2 } from 'three/addons/lines/Line2.js';
import { LineGeometry } from 'three/addons/lines/LineGeometry.js';
import { LineMaterial } from 'three/addons/lines/LineMaterial.js';

export const W = 1280, H = 720, FPS = 30;
export const A0 = 0.035, B0 = 0.132, C0 = -0.020;          // dimensiones reales (planos)

// ---------------------------------------------------------------- utilidades
export function rng(seed = 1) {
  let a = seed >>> 0;
  return () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; };
}
export const clamp = (x, a, b) => Math.min(b, Math.max(a, x));
export const smooth = (x) => { x = clamp(x, 0, 1); return x * x * (3 - 2 * x); };
export const lerp = (a, b, t) => a + (b - a) * t;
export const lerp3 = (p, q, t) => [lerp(p[0], q[0], t), lerp(p[1], q[1], t), lerp(p[2], q[2], t)];
export const seg = (t, t0, t1) => smooth((t - t0) / (t1 - t0));
export const deg = (r) => r * 180 / Math.PI;
export const wrap = (th) => ((th % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI);

// Camara por tramos: keys = [{t, pos, look, fov}], interpolacion suave entre claves consecutivas
export function cameraTrack(keys) {
  return (t) => {
    if (t <= keys[0].t) return keys[0];
    for (let i = 0; i < keys.length - 1; i++) {
      const k0 = keys[i].fn ? { ...keys[i].fn(1, keys[i].t), t: keys[i].t } : keys[i], k1 = keys[i + 1];
      if (t <= k1.t) {
        const u = k1.fn ? (t - k0.t) / (k1.t - k0.t) : seg(t, k0.t, k1.t);
        if (k1.fn) return k1.fn(u, t);
        return { pos: lerp3(k0.pos, k1.pos, u), look: lerp3(k0.look, k1.look, u), fov: lerp(k0.fov || 40, k1.fov || 40, u) };
      }
    }
    const kl = keys[keys.length - 1];
    return kl.fn ? kl.fn(1, t) : kl;
  };
}
export function orbit(center, r, h, ang) { return [center[0] + r * Math.sin(ang), center[1] + h, center[2] + r * Math.cos(ang)]; }

// linea gruesa (Line2): width en pixeles; reveal(f) muestra la fraccion f del trazo
export function fatLine(scene, pts, color, width = 3, o = {}) {
  const g = new LineGeometry(); g.setPositions(pts.flatMap(p => [p.x, p.y, p.z]));
  const m = new LineMaterial({ color, linewidth: width, transparent: true, opacity: 1, depthTest: o.depthTest ?? false, dashed: !!o.dashed, dashSize: o.dash || 0.01, gapSize: o.gap || 0.007 });
  m.resolution.set(1280, 720);
  const l = new Line2(g, m); if (o.dashed) l.computeLineDistances(); l.renderOrder = o.order ?? 10; scene.add(l);
  const nseg = pts.length - 1;
  l.reveal = (f) => { g.instanceCount = Math.max(1, Math.floor(f * nseg)); };
  return l;
}
// ---------------------------------------------------------------- render
export function setup({ bg = 0x1b1f27, exposure = 1.0, envIntensity = 0.6 } = {}) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(1); renderer.setSize(W, H);
  renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = exposure;
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  document.getElementById('stage').appendChild(renderer.domElement);
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(bg);
  const pm = new THREE.PMREMGenerator(renderer);
  scene.environment = pm.fromScene(new RoomEnvironment(), 0.04).texture;
  scene.environmentIntensity = envIntensity;
  const camera = new THREE.PerspectiveCamera(40, W / H, 0.01, 200);
  return { renderer, scene, camera };
}
export function lights(scene, { sun = [4, 8, 3], target = [0, 0, 0], size = 3, intensity = 2.2, hemi = 0.9, mapSize = 2048 } = {}) {
  scene.add(new THREE.HemisphereLight(0xf2f4ff, 0x4a4438, hemi));
  const d = new THREE.DirectionalLight(0xffffff, intensity);
  d.position.set(...sun); d.target.position.set(...target);
  d.castShadow = true; d.shadow.mapSize.set(mapSize, mapSize);
  const c = d.shadow.camera; c.left = -size; c.right = size; c.top = size; c.bottom = -size; c.near = 0.1; c.far = 40;
  d.shadow.bias = -0.0004; d.shadow.normalBias = 0.01;
  scene.add(d); scene.add(d.target);
  return d;
}
export function setCamera(camera, k) {
  camera.position.set(...k.pos); camera.fov = k.fov || 40; camera.updateProjectionMatrix(); camera.lookAt(...k.look); camera.updateMatrixWorld(true);
}

// ---------------------------------------------------------------- materiales
export const mat = (color, o = {}) => new THREE.MeshStandardMaterial({ color, roughness: o.r ?? 0.6, metalness: o.m ?? 0.0, transparent: o.op !== undefined, opacity: o.op ?? 1, side: o.side ?? THREE.FrontSide, depthWrite: o.op === undefined || o.op > 0.6, map: o.map || null, emissive: o.em || 0x000000 });
export const MAT = {
  pla: () => mat(0x8f969e, { r: 0.75 }),
  alu: () => mat(0xc9ced4, { r: 0.35, m: 0.85 }),
  steel: () => mat(0x6b7178, { r: 0.4, m: 0.8 }),
  dark: () => mat(0x2b2f35, { r: 0.6, m: 0.3 }),
  wood: () => mat(0xb98d5b, { r: 0.8 }),
  rubber: () => mat(0x1d1f22, { r: 0.9 }),
  yellow: () => mat(0xf2c12e, { r: 0.5, m: 0.2 }),
  blue: () => mat(0x1f5fd6, { r: 0.45, m: 0.1 }),
  orange: () => mat(0xe8762c, { r: 0.5, m: 0.15 }),
  magenta: () => mat(0xc23b9a, { r: 0.5, m: 0.15 }),
  green: () => mat(0x2f9e5b, { r: 0.55 }),
  glass: () => new THREE.MeshPhysicalMaterial({ color: 0xdfefff, roughness: 0.08, metalness: 0, transmission: 0, transparent: true, opacity: 0.22, depthWrite: false, side: THREE.DoubleSide }),
};
function shadowAll(o, cast = true, recv = true) { o.traverse(m => { if (m.isMesh) { m.castShadow = cast; m.receiveShadow = recv; } }); return o; }
export { shadowAll };

// textura de granos (cafe / alimento) para superficies de material
export function grainTexture(base = '#6b4226', dark = '#3b2414', light = '#8a5a35', seed = 3, n = 900) {
  const cv = document.createElement('canvas'); cv.width = cv.height = 256;
  const g = cv.getContext('2d'); const r = rng(seed);
  g.fillStyle = dark; g.fillRect(0, 0, 256, 256);
  for (let i = 0; i < n; i++) {
    const x = r() * 256, y = r() * 256, a = r() * Math.PI, rx = 5 + r() * 4, ry = 3 + r() * 2.5;
    g.fillStyle = r() < 0.5 ? base : light;
    g.beginPath(); g.ellipse(x, y, rx, ry, a, 0, Math.PI * 2); g.fill();
    g.strokeStyle = dark; g.lineWidth = 1; g.beginPath(); g.moveTo(x - rx * 0.7 * Math.cos(a), y - rx * 0.7 * Math.sin(a)); g.lineTo(x + rx * 0.7 * Math.cos(a), y + rx * 0.7 * Math.sin(a)); g.stroke();
  }
  const t = new THREE.CanvasTexture(cv); t.wrapS = t.wrapT = THREE.RepeatWrapping; t.colorSpace = THREE.SRGBColorSpace;
  return t;
}
export function beltTexture() {
  const cv = document.createElement('canvas'); cv.width = 256; cv.height = 64;
  const g = cv.getContext('2d'); g.fillStyle = '#25282c'; g.fillRect(0, 0, 256, 64);
  const r = rng(9); for (let i = 0; i < 1500; i++) { g.fillStyle = `rgba(255,255,255,${0.02 + r() * 0.04})`; g.fillRect(r() * 256, r() * 64, 2, 1); }
  g.fillStyle = '#3a3e44'; for (let x = 0; x < 256; x += 32) g.fillRect(x, 0, 4, 64);
  const t = new THREE.CanvasTexture(cv); t.wrapS = t.wrapT = THREE.RepeatWrapping; t.colorSpace = THREE.SRGBColorSpace;
  return t;
}

// ---------------------------------------------------------------- cinematica (Norton, rama abierta)
export function kinematics(k = 1) {
  const a = A0 * k, b = B0 * k, c = C0 * k;
  const pos = (th) => { const s = (a * Math.sin(th) - c) / b; const th3 = Math.PI - Math.asin(s); const d = a * Math.cos(th) - b * Math.cos(th3); return { th3, d }; };
  const dmax = Math.sqrt((a + b) ** 2 - c * c), dmin = Math.sqrt((b - a) ** 2 - c * c);
  const thExt = wrap(Math.asin(c / (a + b))), thInt = Math.PI + Math.asin(c / (b - a));
  const vel = (th, w) => { const e = 1e-5; return (pos(th + e).d - pos(th - e).d) / (2 * e) * w; };
  const isAdvance = (th) => { const x = wrap(th); return x >= thInt && x <= thExt; };    // avance: d crece
  return { a, b, c, k, pos, vel, dmax, dmin, S: dmax - dmin, thExt, thInt, isAdvance };
}

// ---------------------------------------------------------------- dosificador parametrico
// opt.style: 'inventor' (colores del modelo de Inventor), 'pla' (gris impreso), 'industrial'
export function buildDoser(k = 1, opt = {}) {
  const K = kinematics(k);
  const s = (v) => v * k;
  const st = opt.style || 'inventor';
  const M = st === 'industrial'
    ? { base: MAT.steel(), sup: mat(0x3b5d8c, { r: 0.5, m: 0.4 }), crank: mat(0xd9502b, { r: 0.45, m: 0.5 }), rod: MAT.yellow(), block: mat(0xb8bec6, { r: 0.3, m: 0.9 }), cover: mat(0x3b5d8c, { r: 0.5, m: 0.4 }), hopper: mat(0x9aa3ad, { r: 0.35, m: 0.85 }), pin: MAT.dark() }
    : st === 'pla'
      ? { base: MAT.pla(), sup: MAT.pla(), crank: MAT.pla(), rod: MAT.pla(), block: MAT.pla(), cover: MAT.pla(), hopper: MAT.pla(), pin: MAT.dark() }
      : { base: mat(0xb9bec4, { r: 0.6 }), sup: mat(0x9aa1a8, { r: 0.6 }), crank: MAT.orange(), rod: MAT.magenta(), block: MAT.blue(), cover: mat(0xaab3bc, { r: 0.5 }), hopper: mat(0xd5d9de, { r: 0.45 }), pin: MAT.dark() };
  if (opt.blockColor !== undefined) M.block = mat(opt.blockColor, { r: 0.45, m: 0.2 });
  if (opt.coverOpacity !== undefined) M.cover = mat(st === 'industrial' ? 0x9fc3e6 : 0xcfe3f5, { r: 0.1, op: opt.coverOpacity, side: THREE.DoubleSide });
  const g = new THREE.Group();
  const yBase = s(-0.070);                       // cara superior de la placa base
  const blockL = s(opt.blockL ?? 0.140), blockH = s(opt.blockH ?? 0.100), blockW = s(opt.blockW ?? 0.140);
  const hopperX = s(0.223 + (opt.hopperShift ?? 0));
  const coverL = s(opt.coverL ?? 0.160);
  const parts = {};

  // placa base (con abertura de descarga opcional)
  const bx0 = s(-0.060), bx1 = s(opt.baseEnd ?? 0.410);
  const addBase = (x0, x1) => { const m = new THREE.Mesh(new THREE.BoxGeometry(x1 - x0, s(0.005), s(0.180)), M.base); m.position.set((x0 + x1) / 2, yBase - s(0.0025), 0); g.add(m); };
  if (opt.outlet) { addBase(bx0, opt.outlet[0]); if (bx1 > opt.outlet[1]) addBase(opt.outlet[1], bx1); } else addBase(bx0, bx1);

  // soporte de la manivela (hoja 1): 40 de ancho, 83.25 de alto, agujero en O2 (70.0 sobre la placa)
  {
    const w2 = s(0.020), y0 = yBase, y1 = yBase + s(0.08325), rr = s(0.008);
    const sh = new THREE.Shape();
    sh.moveTo(-w2, y0); sh.lineTo(w2, y0); sh.lineTo(w2, y1 - rr); sh.absarc(w2 - rr, y1 - rr, rr, 0, Math.PI / 2); sh.lineTo(-w2 + rr, y1); sh.absarc(-w2 + rr, y1 - rr, rr, Math.PI / 2, Math.PI); sh.lineTo(-w2, y0);
    const hole = new THREE.Path(); hole.absarc(0, 0, s(0.0075), 0, Math.PI * 2, true); sh.holes.push(hole);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(sh, { depth: s(0.01131), bevelEnabled: false, curveSegments: 24 }), M.sup);
    m.position.z = s(-0.0293); g.add(m); parts.support = m;
  }
  // eje del disco (pasa por el soporte) y disco-manivela (hoja 2)
  const crank = new THREE.Group(); g.add(crank);
  {
    const shaft = new THREE.Mesh(new THREE.CylinderGeometry(s(0.00725), s(0.00725), s(0.050), 24), M.pin);
    shaft.rotation.x = Math.PI / 2; shaft.position.z = s(-0.010 - 0.025); crank.add(shaft);
    const disk = new THREE.Mesh(new THREE.CylinderGeometry(s(0.045), s(0.045), s(0.005), 64), M.crank);
    disk.rotation.x = Math.PI / 2; disk.position.z = s(-0.0105); crank.add(disk);
    // marca radial para ver el giro
    const mark = new THREE.Mesh(new THREE.BoxGeometry(s(0.030), s(0.004), s(0.0008)), MAT.dark());
    mark.position.set(s(-0.022), 0, s(-0.0078)); crank.add(mark);
    const pinA = new THREE.Mesh(new THREE.CylinderGeometry(s(0.00725), s(0.00725), s(0.020), 20), M.pin);
    pinA.rotation.x = Math.PI / 2; pinA.position.set(K.a, 0, s(-0.004)); crank.add(pinA);
    const capA = new THREE.Mesh(new THREE.CylinderGeometry(s(0.0085), s(0.0085), s(0.003), 20), M.pin);
    capA.rotation.x = Math.PI / 2; capA.position.set(K.a, 0, s(-0.0015)); crank.add(capA);
  }
  // biela (hoja 3): 160 de largo, agujeros a 132 entre centros
  const rod = new THREE.Group(); g.add(rod);
  {
    const e = K.b / 2, r = s(0.014);
    const sh = new THREE.Shape();
    sh.moveTo(-e, -r); sh.lineTo(e, -r); sh.absarc(e, 0, r, -Math.PI / 2, Math.PI / 2); sh.lineTo(-e, r); sh.absarc(-e, 0, r, Math.PI / 2, 3 * Math.PI / 2);
    for (const cx of [-e, e]) { const h = new THREE.Path(); h.absarc(cx, 0, s(0.0075), 0, Math.PI * 2, true); sh.holes.push(h); }
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(sh, { depth: s(0.005), bevelEnabled: false, curveSegments: 20 }), M.rod);
    m.position.z = s(-0.008); rod.add(m);
  }
  // bloque (hoja 4) con oreja y pasador B
  const block = new THREE.Group(); g.add(block);
  {
    const bm = new THREE.Mesh(new THREE.BoxGeometry(blockL, blockH, blockW), M.block);
    bm.position.set(s(0.015) + blockL / 2, yBase + blockH / 2, 0); block.add(bm); parts.blockMesh = bm;
    const lug = new THREE.Mesh(new THREE.BoxGeometry(s(0.030), s(0.030), s(0.018)), M.block);
    lug.position.set(0, K.c, s(0.006)); block.add(lug);
    const pinB = new THREE.Mesh(new THREE.CylinderGeometry(s(0.00725), s(0.00725), s(0.028), 20), M.pin);
    pinB.rotation.x = Math.PI / 2; pinB.position.set(0, K.c, s(0.003)); block.add(pinB);
  }
  // caja-guia (hoja 5): cubierta en U invertida de lamina de 4 mm, boca de 80 mm
  const cover = new THREE.Group(); cover.position.x = hopperX; if (opt.cover !== false) g.add(cover);
  const coverTop = yBase + s(0.101);
  {
    const hw = s(0.07405), t = s(0.004);
    const sh = new THREE.Shape(); sh.moveTo(-coverL / 2, -hw); sh.lineTo(coverL / 2, -hw); sh.lineTo(coverL / 2, hw); sh.lineTo(-coverL / 2, hw); sh.lineTo(-coverL / 2, -hw);
    const hole = new THREE.Path(); hole.absarc(0, 0, s(0.040), 0, Math.PI * 2, true); sh.holes.push(hole);
    const top = new THREE.Mesh(new THREE.ExtrudeGeometry(sh, { depth: t, bevelEnabled: false, curveSegments: 40 }), M.cover);
    top.rotation.x = -Math.PI / 2; top.position.y = coverTop; cover.add(top);
    for (const zs of [-1, 1]) {
      const wall = new THREE.Mesh(new THREE.BoxGeometry(coverL, s(0.101), t), M.cover);
      wall.position.set(0, yBase + s(0.0505), zs * (hw - t / 2)); cover.add(wall);
      const fl = new THREE.Mesh(new THREE.BoxGeometry(coverL, t, s(0.01595)), M.cover);
      fl.position.set(0, yBase + t / 2, zs * (hw + s(0.008))); cover.add(fl);
    }
    if (opt.coverOpacity === undefined) shadowAll(cover);
  }
  // tolva (hoja 6) o silo industrial
  const hopper = new THREE.Group(); hopper.position.set(hopperX, coverTop + s(0.004), 0); g.add(hopper);
  if (opt.hopper === null) { /* sin tolva */ }
  else if ((opt.hopper ?? 'tube') === 'tube') {
    const sh = new THREE.Shape(); sh.absarc(0, 0, s(0.055), 0, Math.PI * 2);
    const h = new THREE.Path(); h.absarc(0, 0, s(0.040), 0, Math.PI * 2, true); sh.holes.push(h);
    const hm = opt.hopperOpacity !== undefined ? mat(0xd7e6f5, { r: 0.1, op: opt.hopperOpacity, side: THREE.DoubleSide }) : M.hopper;
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(sh, { depth: s(0.120), bevelEnabled: false, curveSegments: 48 }), hm);
    if (opt.hopperOpacity !== undefined) m.userData.noShadow = true;
    m.rotation.x = -Math.PI / 2; hopper.add(m); parts.hopperTopY = coverTop + s(0.124);
  } else if (opt.hopper === 'silo') {
    const r0 = s(0.040), R = opt.siloR ?? 0.6, hc = opt.siloCone ?? 0.7, hcyl = opt.siloCyl ?? 0.6;
    const prof = [new THREE.Vector2(r0, 0), new THREE.Vector2(r0, 0.05), new THREE.Vector2(R, 0.05 + hc), new THREE.Vector2(R, 0.05 + hc + hcyl), new THREE.Vector2(R + 0.03, 0.05 + hc + hcyl)];
    const m = new THREE.Mesh(new THREE.LatheGeometry(prof, 48), mat(0xaeb6bf, { r: 0.35, m: 0.85, side: THREE.DoubleSide }));
    hopper.add(m); parts.hopperTopY = coverTop + 0.05 + hc + hcyl;
    // patas del silo
    for (const [sx, sz] of [[1, 1], [1, -1], [-1, 1], [-1, -1]]) {
      const legH = coverTop + 0.05 + hc - (opt.floorY ?? (yBase - 1.2));
      const leg = new THREE.Mesh(new THREE.BoxGeometry(0.06, legH, 0.06), mat(0x3b5d8c, { r: 0.5, m: 0.4 }));
      leg.position.set(sx * (R * 0.78), 0.05 + hc - legH / 2, sz * (R * 0.78)); hopper.add(leg);
    }
    const ring = new THREE.Mesh(new THREE.TorusGeometry(R * 1.0, 0.03, 8, 48), mat(0x3b5d8c, { r: 0.5, m: 0.4 }));
    ring.rotation.x = Math.PI / 2; ring.position.y = 0.05 + hc; hopper.add(ring);
    // superficie del material dentro del silo
    const surf = new THREE.Mesh(new THREE.CircleGeometry(R * 0.97, 48), mat(0xffffff, { r: 0.95, map: opt.grainMap }));
    surf.rotation.x = -Math.PI / 2; surf.position.y = 0.05 + hc + hcyl * 0.75; hopper.add(surf);
  }
  if (opt.hopperFill) {   // superficie de material visible desde arriba en la tolva de tubo
    const surf = new THREE.Mesh(new THREE.CircleGeometry(s(0.0395), 40), mat(0xffffff, { r: 0.95, map: opt.grainMap }));
    surf.rotation.x = -Math.PI / 2; surf.position.y = s(0.105); hopper.add(surf);
  }
  shadowAll(g);
  if (opt.coverOpacity !== undefined) cover.traverse(m => { if (m.isMesh) { m.castShadow = false; m.receiveShadow = false; } });
  hopper.traverse(m => { if (m.isMesh && m.userData.noShadow) { m.castShadow = false; m.receiveShadow = false; } });

  // estado cinematico
  const faceOff = s(0.015) + blockL;            // cara que empuja = B + 15 mm + largo del bloque
  const st8 = { th: 0, d: K.dmin, face: K.dmin + faceOff };
  function update(th) {
    const { th3, d } = K.pos(th);
    crank.rotation.z = th;
    const Ax = K.a * Math.cos(th), Ay = K.a * Math.sin(th);
    rod.position.set((Ax + d) / 2, (Ay + K.c) / 2, 0); rod.rotation.z = th3;
    block.position.x = d;
    st8.th = th; st8.d = d; st8.face = d + faceOff;
    return st8;
  }
  update(0);
  return {
    group: g, K, update, state: st8, parts, crank, rod, block, cover, hopper,
    yBase, coverTop, hopperX, mouth: [hopperX - s(0.040), hopperX + s(0.040)], faceOff,
    faceMin: K.dmin + faceOff, faceMax: K.dmax + faceOff, chanW: s(0.140), blockH,
    A: (th) => new THREE.Vector3(K.a * Math.cos(th), K.a * Math.sin(th), 0), B: () => new THREE.Vector3(st8.d, K.c, 0),
  };
}

// motorreductor pequeno (3-6 V, engranes metalicos) detras del soporte, con soporte de madera
export function smallMotor(k = 1) {
  const g = new THREE.Group();
  const holder = new THREE.Mesh(new THREE.BoxGeometry(0.050, 0.045, 0.040), MAT.wood()); holder.position.set(0, -0.006, -0.068 * k); g.add(holder);
  const gear = new THREE.Mesh(new THREE.BoxGeometry(0.032, 0.022, 0.030), mat(0xd8b23a, { r: 0.4, m: 0.6 })); gear.position.set(0, 0, -0.050 * k + 0.004); g.add(gear);
  const can = new THREE.Mesh(new THREE.CylinderGeometry(0.0115, 0.0115, 0.045, 24), mat(0xc0c4c8, { r: 0.3, m: 0.9 }));
  can.rotation.x = Math.PI / 2; can.position.set(0, 0, -0.105 * k + 0.012); g.add(can);
  const coup = new THREE.Mesh(new THREE.BoxGeometry(0.014, 0.014, 0.012), mat(0x2f8fd8, { r: 0.4 })); coup.position.set(0, 0, -0.033 * k); g.add(coup);
  return shadowAll(g);
}
// motorreductor industrial con caja de engranes
export function industrialMotor(k = 4) {
  const g = new THREE.Group(); const blue = mat(0x2d5f9e, { r: 0.45, m: 0.5 });
  const gb = new THREE.Mesh(new THREE.BoxGeometry(0.26, 0.26, 0.20), blue); gb.position.set(0, -0.02, -0.30); g.add(gb);
  const mo = new THREE.Mesh(new THREE.CylinderGeometry(0.10, 0.10, 0.32, 32), blue); mo.rotation.z = Math.PI / 2; mo.position.set(-0.27, -0.02, -0.30); g.add(mo);
  for (let i = 0; i < 10; i++) { const fin = new THREE.Mesh(new THREE.TorusGeometry(0.101, 0.006, 6, 32), blue); fin.rotation.y = Math.PI / 2; fin.position.set(-0.17 - i * 0.022, -0.02, -0.30); g.add(fin); }
  const base = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.03, 0.3), MAT.steel()); base.position.set(-0.12, -0.165, -0.30); g.add(base);
  return shadowAll(g);
}

// ---------------------------------------------------------------- nube de puntos (estilo levantamiento laser)
export function pointCloud(scene, o) {
  const r = rng(o.seed || 7);
  const P = [], C = [];
  const add = (x, y, z, col, j = 0.06) => { const n = (r() - 0.5) * j; P.push(x, y, z); C.push(clamp(col[0] + n, 0, 1), clamp(col[1] + n, 0, 1), clamp(col[2] + n, 0, 1)); };
  const [X0, X1] = o.x, [Z0, Z1] = o.z, Hh = o.h, y0 = o.y0 ?? 0;
  const scan = o.scanner || [(X0 + X1) / 2, (Z0 + Z1) / 2];
  const keep = (x, z) => { const dd = Math.hypot(x - scan[0], z - scan[1]); return r() < clamp(1.4 - dd / (o.reach || 14), 0.15, 1); };
  const holes = []; for (let i = 0; i < (o.holes ?? 40); i++) holes.push([lerp(X0, X1, r()), lerp(Z0, Z1, r()), 0.2 + r() * 0.9]);
  const inHole = (x, z) => holes.some(h => (x - h[0]) ** 2 + (z - h[1]) ** 2 < h[2] * h[2]);
  // piso de concreto con lineas amarillas y manchas
  const nF = o.nFloor ?? 140000;
  for (let i = 0; i < nF; i++) {
    const x = lerp(X0, X1, r()), z = lerp(Z0, Z1, r());
    if (!keep(x, z) || inHole(x, z) || (o.clearFloor && o.clearFloor(x, z))) continue;
    let col = [0.56, 0.56, 0.54];
    if ((o.yellow || []).some(L => (L.axis === 'x' ? Math.abs(z - L.at) < L.w / 2 && x > L.from && x < L.to : Math.abs(x - L.at) < L.w / 2 && z > L.from && z < L.to))) col = [0.92, 0.74, 0.12];
    else if (Math.sin(x * 1.3 + z * 0.7) + Math.sin(x * 0.4 - z * 2.1) > 1.3) col = [0.45, 0.45, 0.44];
    add(x, y0 + (r() - 0.5) * 0.004, z, col, 0.08);
  }
  // paredes: blanco con parches azules (pintura) y franja de ventanas
  const wall = (n, f) => { for (let i = 0; i < n; i++) { const u = r(), v = r(); const [x, y, z] = f(u, v); if (!keep(x, z)) continue; add(x, y, z, wallColor(u, v, y)); } };
  const blob = []; for (let i = 0; i < 70; i++) blob.push([r(), r() * 0.55, 0.02 + r() * 0.06]);
  function wallColor(u, v, y) {
    const hv = (y - y0) / Hh;
    if (hv > 0.62 && hv < 0.8 && (Math.floor(u * 18) % 3 !== 0)) return [0.78, 0.86, 0.93];
    if (blob.some(b => (u - b[0]) ** 2 + ((hv - b[1]) * 0.5) ** 2 < b[2] * b[2])) return [0.16, 0.42, 0.74];
    if (hv < 0.06) return [0.22, 0.45, 0.72];
    return [0.86, 0.87, 0.86];
  }
  const nW = o.nWall ?? 45000;
  if (o.walls?.includes('back')) wall(nW, (u, v) => [lerp(X0, X1, u), y0 + v * Hh, Z0]);
  if (o.walls?.includes('left')) wall(nW * 0.6, (u, v) => [X0, y0 + v * Hh, lerp(Z0, Z1, u)]);
  if (o.walls?.includes('right')) wall(nW * 0.6, (u, v) => [X1, y0 + v * Hh, lerp(Z0, Z1, u)]);
  // objetos escaneados: cajas de puntos (anaqueles, maquinas, cajas)
  for (const b of (o.boxes || [])) {
    const [cx, cy, cz] = b.c, [sx, sy, sz] = b.s, n = b.n || Math.round(2500 * (sx * sy + sy * sz + sx * sz));
    for (let i = 0; i < n; i++) {
      const f = Math.floor(r() * 5), u = r() - 0.5, v = r() - 0.5;
      let p;
      if (f === 0) p = [cx + u * sx, cy + sy / 2, cz + v * sz];
      else if (f === 1) p = [cx + sx / 2, cy + u * sy, cz + v * sz];
      else if (f === 2) p = [cx - sx / 2, cy + u * sy, cz + v * sz];
      else if (f === 3) p = [cx + u * sx, cy + v * sy, cz + sz / 2];
      else p = [cx + u * sx, cy + v * sy, cz - sz / 2];
      add(p[0], p[1], p[2], b.col || [0.4, 0.4, 0.42], 0.1);
    }
  }
  // anaqueles con cajas azules
  for (const sh of (o.shelves || [])) {
    const [cx, cz] = sh.c, L = sh.L, D = sh.D || 0.6, levels = sh.levels || 4, Hs = sh.H || 2;
    for (let l = 0; l < levels; l++) {
      const y = y0 + 0.3 + l * (Hs - 0.3) / (levels - 1);
      for (let i = 0; i < 1800; i++) { const u = r() - 0.5, v = r() - 0.5; add(cx + u * L, y, cz + v * D, [0.55, 0.55, 0.58], 0.05); }
      for (let bx = -L / 2 + 0.25; bx < L / 2 - 0.2; bx += 0.42) {
        if (r() < 0.25) continue;
        for (let i = 0; i < 260; i++) { const u = r() - 0.5, v = r(), w = r() - 0.5; add(cx + bx + u * 0.36, y + v * 0.22, cz + w * D * 0.8, [0.12, 0.36, 0.78], 0.08); }
      }
    }
    for (const px of [-L / 2, L / 2]) for (const pz of [-D / 2, D / 2]) for (let i = 0; i < 500; i++) add(cx + px, y0 + r() * Hs, cz + pz, [0.25, 0.42, 0.65], 0.05);
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.Float32BufferAttribute(P, 3));
  geo.setAttribute('color', new THREE.Float32BufferAttribute(C, 3));
  const cv = document.createElement('canvas'); cv.width = cv.height = 32; const c2 = cv.getContext('2d');
  const grd = c2.createRadialGradient(16, 16, 0, 16, 16, 16); grd.addColorStop(0, 'rgba(255,255,255,1)'); grd.addColorStop(0.7, 'rgba(255,255,255,1)'); grd.addColorStop(1, 'rgba(255,255,255,0)');
  c2.fillStyle = grd; c2.fillRect(0, 0, 32, 32);
  const pts = new THREE.Points(geo, new THREE.PointsMaterial({ size: o.size || 0.02, vertexColors: true, map: new THREE.CanvasTexture(cv), alphaTest: 0.5, sizeAttenuation: true }));
  scene.add(pts);
  if (o.solidFloor !== false) {   // piso de fondo tenue bajo los puntos (da continuidad a la nube)
    const fl = new THREE.Mesh(new THREE.PlaneGeometry(X1 - X0, Z1 - Z0), new THREE.MeshStandardMaterial({ color: o.floorColor ?? 0x2e3136, roughness: 1 }));
    fl.rotation.x = -Math.PI / 2; fl.position.set((X0 + X1) / 2, y0 - 0.004, (Z0 + Z1) / 2); fl.receiveShadow = true; scene.add(fl);
  }
  return pts;
}

// ---------------------------------------------------------------- transportadores
export function beltConveyor({ len, width, height, belt = beltTexture(), frame = MAT.alu(), legs = true }) {
  const g = new THREE.Group();
  const top = new THREE.Mesh(new THREE.BoxGeometry(len, 0.012, width), mat(0xffffff, { r: 0.85, map: belt }));
  belt.repeat.set(len / 0.25, 1); top.position.y = height; g.add(top);
  for (const zs of [-1, 1]) {
    const rail = new THREE.Mesh(new THREE.BoxGeometry(len + 0.04, 0.05, 0.02), frame); rail.position.set(0, height - 0.01, zs * (width / 2 + 0.012)); g.add(rail);
  }
  for (const xs of [-1, 1]) {
    const roll = new THREE.Mesh(new THREE.CylinderGeometry(0.035, 0.035, width, 24), MAT.steel()); roll.rotation.x = Math.PI / 2; roll.position.set(xs * len / 2, height - 0.03, 0); g.add(roll);
  }
  if (legs) {
    const nl = Math.max(2, Math.round(len / 1.2) + 1);
    for (let i = 0; i < nl; i++) for (const zs of [-1, 1]) {
      const leg = new THREE.Mesh(new THREE.BoxGeometry(0.04, height - 0.03, 0.04), frame); leg.position.set(-len / 2 + 0.05 + i * (len - 0.1) / (nl - 1), (height - 0.03) / 2, zs * (width / 2 + 0.012)); g.add(leg);
    }
  }
  shadowAll(g);
  return { group: g, setPos(p) { belt.offset.x = -p / 0.25; } };
}
export function rollerConveyor({ len, width, height, pitch = 0.09, frame = MAT.alu() }) {
  const g = new THREE.Group(); const rolls = [];
  const n = Math.floor(len / pitch);
  for (let i = 0; i <= n; i++) { const rl = new THREE.Mesh(new THREE.CylinderGeometry(0.024, 0.024, width, 16), mat(0xb7bec6, { r: 0.3, m: 0.9 })); rl.rotation.x = Math.PI / 2; rl.position.set(-len / 2 + i * pitch, height, 0); g.add(rl); rolls.push(rl);
    const mk = new THREE.Mesh(new THREE.BoxGeometry(0.006, 0.05, width * 0.98), MAT.dark()); mk.visible = false; }
  for (const zs of [-1, 1]) { const rail = new THREE.Mesh(new THREE.BoxGeometry(len + 0.05, 0.07, 0.03), frame); rail.position.set(0, height - 0.022, zs * (width / 2 + 0.02)); g.add(rail); }
  const nl = Math.max(2, Math.round(len / 1.0) + 1);
  for (let i = 0; i < nl; i++) for (const zs of [-1, 1]) { const leg = new THREE.Mesh(new THREE.BoxGeometry(0.045, height, 0.045), frame); leg.position.set(-len / 2 + 0.05 + i * (len - 0.1) / (nl - 1), height / 2, zs * (width / 2 + 0.02)); g.add(leg); }
  shadowAll(g);
  return { group: g, setPos(p) { for (const rl of rolls) rl.rotation.y = -p / 0.024; } };
}
// perfil de aluminio (marco estructural)
export function aluFrame(boxes, material = MAT.alu()) {
  const g = new THREE.Group();
  for (const [x0, y0, z0, x1, y1, z1] of boxes) { const m = new THREE.Mesh(new THREE.BoxGeometry(Math.abs(x1 - x0) || 0.04, Math.abs(y1 - y0) || 0.04, Math.abs(z1 - z0) || 0.04), material); m.position.set((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2); g.add(m); }
  return shadowAll(g);
}

// ---------------------------------------------------------------- particulas (chorro de material)
export class Particles {
  constructor(scene, { max = 4000, size = 0.008, colors = [0x6b4226, 0x5a3820, 0x7a4c2c], shape = 'bean', seed = 11 }) {
    let geo;
    if (shape === 'bean') { geo = new THREE.SphereGeometry(size / 2, 7, 5); geo.scale(1, 0.62, 0.78); }
    else if (shape === 'pellet') { geo = new THREE.CylinderGeometry(size * 0.28, size * 0.28, size, 6); geo.rotateZ(Math.PI / 2); }
    else geo = new THREE.BoxGeometry(size, size, size);
    this.mesh = new THREE.InstancedMesh(geo, new THREE.MeshStandardMaterial({ roughness: 0.7, metalness: 0 }), max);
    this.mesh.castShadow = true; this.mesh.receiveShadow = true;
    this.mesh.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
    const col = new THREE.Color();
    this.r = rng(seed);
    for (let i = 0; i < max; i++) { col.setHex(colors[Math.floor(this.r() * colors.length)]); this.mesh.setColorAt(i, col); }
    scene.add(this.mesh);
    this.max = max; this.p = []; this.free = []; for (let i = max - 1; i >= 0; i--) this.free.push(i);
    this.m4 = new THREE.Matrix4(); this.q = new THREE.Quaternion(); this.e = new THREE.Euler(); this.v = new THREE.Vector3(); this.one = new THREE.Vector3(1, 1, 1);
    this.zero = new THREE.Matrix4().makeScale(0, 0, 0);
    for (let i = 0; i < max; i++) this.mesh.setMatrixAt(i, this.zero);
  }
  // p: {x,y,z,vx,vy,vz, mode, ...}
  spawn(p) {
    if (!this.free.length) return null;
    const id = this.free.pop();
    Object.assign(p, { id, rx: this.r() * 6, ry: this.r() * 6, rz: this.r() * 6, wr: (this.r() - 0.5) * 20, age: 0 });
    this.p.push(p); return p;
  }
  kill(p) { this.mesh.setMatrixAt(p.id, this.zero); this.free.push(p.id); p.dead = true; }
  step(dt, fn) {
    for (const p of this.p) { if (p.dead) continue; p.age += dt; fn(p, dt); }
    this.p = this.p.filter(p => !p.dead);
  }
  sync() {
    for (const p of this.p) {
      this.e.set(p.rx + p.wr * p.age * (p.spin ?? 1), p.ry, p.rz); this.q.setFromEuler(this.e);
      this.m4.compose(this.v.set(p.x, p.y, p.z), this.q, this.one); this.mesh.setMatrixAt(p.id, this.m4);
    }
    this.mesh.instanceMatrix.needsUpdate = true;
  }
}

// ---------------------------------------------------------------- HUD (HTML sobre el lienzo)
export function hudCSS() {
  const css = `
  #stage{position:absolute;inset:0;width:${W}px;height:${H}px}
  .hud{position:absolute;font-family:'Liberation Sans',Arial,sans-serif;color:#fff;pointer-events:none}
  .panel{background:rgba(14,18,26,.72);border:1px solid rgba(255,255,255,.14);border-radius:10px;padding:10px 14px;backdrop-filter:blur(2px)}
  #title{left:28px;top:24px;max-width:760px}
  #title .k{font-size:13px;letter-spacing:.14em;text-transform:uppercase;color:#7fc3ff;font-weight:700}
  #title .t{font-size:30px;font-weight:700;line-height:1.15;margin-top:4px;text-shadow:0 2px 8px rgba(0,0,0,.5)}
  #title .s{font-size:15px;color:#d8e3ef;margin-top:6px;line-height:1.35}
  #data{right:24px;top:24px;width:262px;font-size:14px}
  #data .row{display:flex;justify-content:space-between;padding:2px 0;font-variant-numeric:tabular-nums}
  #data .lab{color:#b9c6d6}
  #data .val{font-weight:700}
  #data h4{margin:0 0 6px 0;font-size:12px;letter-spacing:.12em;text-transform:uppercase;color:#7fc3ff}
  .phase{display:inline-block;padding:1px 8px;border-radius:6px;font-weight:700;font-size:13px}
  #cap{left:50%;bottom:30px;transform:translateX(-50%);max-width:980px;text-align:center;font-size:20px;line-height:1.35;padding:10px 18px}
  #foot{left:24px;bottom:10px;font-size:11px;color:rgba(255,255,255,.75)}
  #plot{right:24px;width:262px}
  .lbl{position:absolute;font-family:'Liberation Sans',Arial,sans-serif;font-size:15px;font-weight:700;color:#fff;background:rgba(14,18,26,.78);border-radius:6px;padding:2px 8px;transform:translate(-50%,-50%);white-space:nowrap;border:1px solid rgba(255,255,255,.2)}
  .fade{transition:none}
  `;
  const s = document.createElement('style'); s.textContent = css; document.head.appendChild(s);
}
export function el(html, id, cls = 'hud') { const d = document.createElement('div'); d.className = cls; if (id) d.id = id; d.innerHTML = html; document.body.appendChild(d); return d; }

// grafica pequena d(θ2) o V_B(θ2) con marcador
export function miniPlot(container, K, { w = 234, h = 120, what = 'v', omega = Math.PI, label = 'V_B (mm/s) vs θ₂' } = {}) {
  const N = 360, xs = [], ys = [];
  for (let i = 0; i <= N; i++) { const th = i / N * 2 * Math.PI; xs.push(i); ys.push(what === 'v' ? K.vel(th, omega) * 1000 : K.pos(th).d * 1000); }
  const y0 = Math.min(...ys), y1 = Math.max(...ys);
  const X = (i) => 8 + i / N * (w - 16), Y = (v) => h - 18 - (v - y0) / (y1 - y0) * (h - 34);
  let path = ''; for (let i = 0; i <= N; i++) path += (i ? 'L' : 'M') + X(i).toFixed(1) + ' ' + Y(ys[i]).toFixed(1);
  const zero = what === 'v' ? `<line x1="8" x2="${w - 8}" y1="${Y(0)}" y2="${Y(0)}" stroke="rgba(255,255,255,.25)" stroke-dasharray="3 3"/>` : '';
  container.innerHTML = `<div style="font-size:12px;letter-spacing:.1em;text-transform:uppercase;color:#7fc3ff;font-weight:700;margin-bottom:2px">${label}</div>
    <svg width="${w}" height="${h}">${zero}<path d="${path}" fill="none" stroke="#ffb347" stroke-width="2"/>
    <line id="pl_v" x1="0" x2="0" y1="6" y2="${h - 16}" stroke="rgba(255,255,255,.35)"/><circle id="pl_dot" r="5" fill="#fff" stroke="#ffb347" stroke-width="2"/>
    <text x="8" y="${h - 3}" fill="#9fb0c4" font-size="10">0°</text><text x="${w - 30}" y="${h - 3}" fill="#9fb0c4" font-size="10">360°</text></svg>`;
  const dot = container.querySelector('#pl_dot'), vl = container.querySelector('#pl_v');
  return (th) => { const i = wrap(th) / (2 * Math.PI) * N; const v = what === 'v' ? K.vel(th, omega) * 1000 : K.pos(th).d * 1000; dot.setAttribute('cx', X(i)); dot.setAttribute('cy', Y(v)); vl.setAttribute('x1', X(i)); vl.setAttribute('x2', X(i)); };
}
export function project(v, camera) { const p = v.clone().project(camera); return [(p.x + 1) / 2 * W, (1 - p.y) / 2 * H, p.z]; }
export function fadeIn(elm, t, t0, t1, t2, t3) { const o = t < t0 || t > t3 ? 0 : t < t1 ? (t - t0) / (t1 - t0) : t < t2 ? 1 : (t3 - t) / (t3 - t2); elm.style.opacity = clamp(o, 0, 1); return o; }

// ---------------------------------------------------------------- flujo de material en el dosificador
// Modelo: flujo tapon. La capa de altura h ocupa el canal desde la cara del bloque hasta el borde de
// descarga (lip). En el avance toda la capa se mueve con la cara y lo que pasa el borde cae; en el
// retorno la capa queda quieta y el hueco que deja el bloque se llena desde la boca de la tolva.
export class DoserFlow {
  constructor(scene, D, O, o) {
    this.D = D; this.O = O; this.o = o; this.K = D.K;
    const yB = D.yBase, h = o.h, w = D.chanW * 0.985;
    this.lip = o.lip; this.h = h; this.matShift = 0; this.acc = 0; this.accC = 0;
    this.grain = o.grainMap;
    // capa de material (tapon) y columna bajo la boca
    const tex = o.grainMap.clone(); tex.needsUpdate = true; this.tex = tex;
    this.slug = new THREE.Mesh(new THREE.BoxGeometry(1, h, w), mat(0xffffff, { r: 0.9, map: tex }));
    this.slug.position.set(0, O.y + yB + h / 2, O.z); this.slug.receiveShadow = true; scene.add(this.slug);
    const tex2 = o.grainMap.clone(); tex2.needsUpdate = true; tex2.repeat.set(2, 2);
    const colH = D.coverTop - (yB + h);
    this.col = new THREE.Mesh(new THREE.BoxGeometry(1, colH, D.K.k * 0.080), mat(0xffffff, { r: 0.9, map: tex2 }));
    this.col.position.set(0, O.y + yB + h + colH / 2, O.z); scene.add(this.col);
    if (o.showInside === false) { this.slug.visible = false; this.col.visible = false; }
    // compuerta reguladora en el borde de aguas abajo de la boca
    if (o.gate !== false) {
      const gh = D.coverTop - (yB + h);
      const gate = new THREE.Mesh(new THREE.BoxGeometry(D.K.k * 0.003, gh, w), mat(0x7d8792, { r: 0.35, m: 0.8 }));
      gate.position.set(O.x + D.mouth[1] + D.K.k * 0.0015, O.y + yB + h + gh / 2, O.z); scene.add(gate); this.gate = gate;
    }
    this.P = new Particles(scene, o.particles);
    this.r = rng(o.seed || 5);
    this.prevFace = null;
  }
  // avanza la simulacion de t0 a t1 (s); thAt(t) da el angulo de la manivela
  step(t0, t1, thAt, omega, nsub = 8) {
    const D = this.D, O = this.O, o = this.o, K = this.K, g = 9.81;
    const dt = (t1 - t0) / nsub;
    for (let k = 1; k <= nsub; k++) {
      const t = t0 + k * dt, th = thAt(t);
      const face = K.pos(th).d + D.faceOff, V = K.vel(th, omega);
      if (this.prevFace === null) this.prevFace = face;
      const dF = face - this.prevFace; this.prevFace = face;
      if (dF > 0) this.matShift += dF;
      if (o.onSub) o.onSub(t, th);
      // emision en el borde de descarga (avance)
      if (V > 0) {
        this.acc += o.nd * V * dt;
        while (this.acc >= 1) {
          this.acc -= 1; const r = this.r;
          this.P.spawn({ x: O.x + this.lip + r() * 0.004 * K.k, y: O.y + D.yBase + r() * this.h, z: O.z + (r() - 0.5) * D.chanW * 0.9, vx: V * (0.85 + 0.3 * r()), vy: -r() * 0.05, vz: 0, mode: 'fall' });
        }
      } else if (o.curtain) {   // cortina que cae de la boca al hueco que abre el bloque
        this.accC += o.curtain * (-V) * dt;
        while (this.accC >= 1) {
          this.accC -= 1; const r = this.r;
          const x = face + r() * Math.min(0.012 * K.k, D.mouth[1] - face);
          this.P.spawn({ x: O.x + x, y: O.y + D.coverTop - r() * 0.01 * K.k, z: O.z + (r() - 0.5) * 0.07 * K.k, vx: 0, vy: -0.2, vz: 0, mode: 'curtain' });
        }
      }
      const sp = o.spout, yTop = O.y + D.yBase - 0.004 * K.k;
      this.P.step(dt, (p, dt) => {
        if (p.mode === 'rest') { o.rest(p, dt); return; }
        p.vy -= g * dt; p.y += p.vy * dt;
        if (p.mode === 'curtain') { if (p.y <= O.y + D.yBase + this.h) this.P.kill(p); return; }
        if (p.mode === 'fall') {
          p.x += p.vx * dt; p.z += p.vz * dt;
          if (sp && p.y < sp.yTop) p.mode = 'funnel';
        } else if (p.mode === 'funnel') {
          const f = 1 - Math.exp(-dt * sp.pull);
          p.x += (sp.x - p.x) * f; p.z += (sp.z - p.z) * f;
          if (p.y < sp.yExit) { p.mode = 'drop'; p.x = sp.x + (this.r() - 0.5) * sp.jit; p.z = sp.z + (this.r() - 0.5) * sp.jit; }
        }
        if (p.mode === 'drop' || (!sp && p.mode === 'fall')) {
          const land = o.landing(p);
          if (land && p.y <= land.y) { p.y = land.y; p.mode = 'rest'; p.age = 0; land.attach(p); }
          else if (p.y < -1) this.P.kill(p);
        }
      });
    }
    // capa y columna
    const th = thAt(t1), face = K.pos(th).d + D.faceOff;
    const len = Math.max(0.001, this.lip - face);
    this.slug.scale.x = len; this.slug.position.x = O.x + face + len / 2;
    this.tex.repeat.set(len / (0.05 * K.k), this.h / (0.05 * K.k));
    this.tex.offset.x = (face - this.matShift) / (0.05 * K.k);
    const cl = Math.max(0.0005, D.mouth[1] - face);
    this.col.scale.x = cl; this.col.position.x = O.x + face + cl / 2; this.col.visible = this.o.showInside !== false && cl > 0.001;
  }
  sync() { this.P.sync(); }
}
