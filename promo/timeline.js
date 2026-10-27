const puppeteer = require('puppeteer-core'); const path = require('path');
(async () => {
  const b = await puppeteer.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', headless: true, args: ['--allow-file-access-from-files'] });
  const p = await b.newPage(); await p.goto('file://' + path.join(__dirname, 'film.html')); await p.evaluate(() => window.ready);
  const out = await p.evaluate(() => {
    const ticks = []; let prev = Tat(0);
    for (let i = 1; i < 53 * 600; i++) { const t = i / 600, T = Tat(t); if (t < 26 && Math.floor(T) > Math.floor(prev)) ticks.push(+t.toFixed(4)); prev = T; }
    return { cross: T_CROSS, ticks };
  });
  console.log(JSON.stringify(out)); await b.close();
})();
