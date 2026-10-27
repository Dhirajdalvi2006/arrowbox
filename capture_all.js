const { chromium } = require('playwright');
const http = require('http');
const fs = require('fs');
const path = require('path');

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.ico': 'image/x-icon'
};

async function run() {
  const webDir = path.join(__dirname, 'build', 'web');
  const outDir = path.join(__dirname, 'screenshots', 'arrowbox');
  fs.mkdirSync(outDir, { recursive: true });

  const server = http.createServer((req, res) => {
    const urlObj = new URL(req.url, 'http://localhost:8080');
    let pathname = urlObj.pathname === '/' ? 'index.html' : urlObj.pathname;
    let filePath = path.join(webDir, pathname);

    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(webDir, 'index.html');
    }
    const ext = path.extname(filePath);
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Not found');
      } else {
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(data);
      }
    });
  });

  await new Promise((resolve) => server.listen(8080, resolve));
  console.log('Server running on http://localhost:8080');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 412, height: 915 },
    deviceScaleFactor: 2
  });
  const page = await context.newPage();

  const screens = [
    { url: 'http://localhost:8080', name: '01_landing.png' },
    { url: 'http://localhost:8080/?screen=levels', name: '02_level_selection.png' },
    { url: 'http://localhost:8080/?screen=gameplay', name: '03_gameplay.png' },
    { url: 'http://localhost:8080/?screen=pause', name: '04_pause.png' },
    { url: 'http://localhost:8080/?screen=complete', name: '05_level_complete.png' },
    { url: 'http://localhost:8080/?screen=gameover', name: '06_game_over.png' },
    { url: 'http://localhost:8080/?screen=settings', name: '07_settings.png' },
    { url: 'http://localhost:8080/?screen=progress', name: '08_progress.png' },
    { url: 'http://localhost:8080/?screen=howtoplay', name: '09_how_to_play.png' },
    { url: 'http://localhost:8080/?screen=about', name: '10_about.png' },
  ];

  try {
    // Seed localStorage once
    await page.goto('http://localhost:8080', { waitUntil: 'networkidle' });
    await page.evaluate(() => {
      localStorage.setItem('flutter.unlockedLevel', 3);
      localStorage.setItem('flutter.completedLevels', JSON.stringify(['1', '2']));
      localStorage.setItem('flutter.gamesPlayed', 5);
      localStorage.setItem('flutter.totalMistakes', 8);
      localStorage.setItem('flutter.themeMode', 2);
    });

    for (const s of screens) {
      console.log(`Capturing ${s.name} from ${s.url}...`);
      await page.goto(s.url, { waitUntil: 'networkidle' });
      await page.waitForTimeout(2500); // Wait for Flutter render
      await page.screenshot({ path: path.join(outDir, s.name) });
    }

    // Now switch to Light Mode and capture key light mode screens
    await page.evaluate(() => {
      localStorage.setItem('flutter.themeMode', 1); // ThemeMode.light
    });

    const lightScreens = [
      { url: 'http://localhost:8080', name: '11_landing_light.png' },
      { url: 'http://localhost:8080/?screen=levels', name: '12_level_selection_light.png' },
      { url: 'http://localhost:8080/?screen=gameplay', name: '13_gameplay_light.png' },
      { url: 'http://localhost:8080/?screen=settings', name: '14_settings_light.png' },
      { url: 'http://localhost:8080/?screen=progress', name: '15_progress_light.png' },
    ];

    for (const s of lightScreens) {
      console.log(`Capturing ${s.name} from ${s.url}...`);
      await page.goto(s.url, { waitUntil: 'networkidle' });
      await page.waitForTimeout(2500);
      await page.screenshot({ path: path.join(outDir, s.name) });
    }

    console.log('ALL SCREENS CAPTURED SUCCESSFULLY (DARK & LIGHT)!');
  } catch (err) {
    console.error('Error during capture:', err);
  } finally {
    await browser.close();
    server.close();
  }
}

run();
