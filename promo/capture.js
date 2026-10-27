// node capture.js stills 0,5,13 outdir   |   node capture.js video out.mp4 ffmpegPath
// add 'vertical' as a last argument for the 9:16 story cut
const puppeteer = require('puppeteer-core');
const { spawn } = require('child_process');
const path = require('path');
const FPS = 60, DUR = 55;

(async () => {
  const [mode, a, b, fmt] = process.argv.slice(2);
  const vert = fmt === 'vertical', W = vert ? 1080 : 1920, H = vert ? 1920 : 1080;
  const browser = await puppeteer.launch({
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: true, args: ['--allow-file-access-from-files', '--force-color-profile=srgb', '--hide-scrollbars'],
  });
  const page = await browser.newPage(); page.on('pageerror', e => console.error('PAGEERR', e.message)); page.on('console', m => console.log('CONSOLE', m.text()));
  await page.setViewport({ width: W, height: H, deviceScaleFactor: 1 });
  await page.goto('file://' + path.join(__dirname, 'film.html') + (vert ? '?vertical' : ''));
  await page.evaluate(() => window.ready);
  const shot = async t => { await page.evaluate(t => window.render(t), t); return page.screenshot({ type: 'png', clip: { x: 0, y: 0, width: W, height: H }, omitBackground: false }); };

  if (mode === 'stills') {
    const fs = require('fs');
    for (const t of a.split(',').map(Number)) fs.writeFileSync(path.join(b, `still_${t}.png`), await shot(t));
  } else {
    const ff = spawn(b, ['-y', '-f', 'image2pipe', '-framerate', String(FPS), '-c:v', 'png', '-i', '-',
      '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '14', '-preset', 'slow', '-tune', 'animation',
      '-colorspace', 'bt709', '-color_primaries', 'bt709', '-color_trc', 'bt709',
      '-movflags', '+faststart', a], { stdio: ['pipe', 'inherit', 'inherit'] });
    const N = FPS * DUR;
    for (let i = 0; i < N; i++) {
      const buf = await shot(i / FPS);
      if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
      if (i % 300 === 0) console.log(`frame ${i}/${N}`);
    }
    ff.stdin.end();
    await new Promise(r => ff.on('close', r));
  }
  await browser.close();
})();
