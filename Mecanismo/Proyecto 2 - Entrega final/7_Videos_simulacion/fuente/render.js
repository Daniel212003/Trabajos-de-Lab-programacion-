// Necesita: npm install three@0.170.0 playwright ; y un servidor local: python -m http.server 8123
// Uso: node render.js escena.html salida.mp4            -> video completo
//      node render.js escena.html prefijo --stills 0,90,300 -> cuadros sueltos en JPG
const { chromium } = require('playwright');
const { spawn } = require('child_process');
const [, , html, out, mode, list] = process.argv;
const PORT = process.env.PORT || 8123;
(async () => {
  const browser = await chromium.launch({ args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
  page.on('console', m => { if (m.type() === 'error' || m.type() === 'warning') console.log('console:', m.text()); });
  page.on('pageerror', e => console.log('pageerror:', e.message));
  await page.goto(`http://127.0.0.1:${PORT}/${html}`);
  await page.waitForFunction('window.ready === true', null, { timeout: 120000 });
  const dur = await page.evaluate(() => window.DUR);
  const runFrame = async (i) => { const err = await page.evaluate(i => { try { window.frame(i); return null; } catch (e) { return e.stack; } }, i); if (err) { console.log('ERROR cuadro', i, err); process.exit(1); } };
  const N = Math.round(dur * 30);
  const t0 = Date.now();
  if (mode === '--stills') {
    const frames = list.split(',').map(Number);
    let last = -1;
    for (const f of frames) {
      if (await page.evaluate(() => !!window.sequential)) { await page.evaluate(() => { window.skipRender = true; }); for (let i = last + 1; i < f; i++) await runFrame(i); await page.evaluate(() => { window.skipRender = false; }); }
      await runFrame(f); last = f;
      await page.screenshot({ path: `${out}_${String(f).padStart(4, '0')}.jpg`, type: 'jpeg', quality: 88, timeout: 300000 });
    }
  } else {
    const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', '30', '-c:v', 'mjpeg', '-i', '-',
      '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', out]);
    ff.stderr.on('data', d => process.stderr.write(d));
    for (let i = 0; i < N; i++) {
      await runFrame(i);
      const buf = await page.screenshot({ type: 'jpeg', quality: 93, timeout: 300000 });
      if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
      if (i % 60 === 0) console.log(`${html}: ${i}/${N}  ${((Date.now() - t0) / 1000).toFixed(0)} s`);
    }
    ff.stdin.end(); await new Promise(r => ff.on('close', r));
  }
  console.log('listo', out, ((Date.now() - t0) / 1000).toFixed(0), 's');
  await browser.close();
})();
