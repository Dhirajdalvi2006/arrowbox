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
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.ico': 'image/x-icon'
};

async function run() {
  const webDir = path.join(__dirname, 'build', 'web');

  const server = http.createServer((req, res) => {
    let filePath = path.join(webDir, req.url === '/' ? 'index.html' : req.url);
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

  await new Promise((resolve) => server.listen(8000, resolve));
  console.log('Server running on http://localhost:8000');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 412, height: 915 }
  });
  const page = await context.newPage();

  try {
    console.log('Navigating to app...');
    await page.goto('http://localhost:8000', { waitUntil: 'networkidle' });

    console.log('Waiting for splash screen...');
    await page.waitForTimeout(4000);

    // 1. Home
    console.log('Capturing Home...');
    await page.screenshot({ path: 'screenshots/visual-audit/01_home.png', fullPage: true });

    // 2. All Games (click Games tab)
    console.log('Navigating to All Games...');
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const tab = items.find(el => el.textContent && el.textContent.trim() === 'Games');
      if (tab) tab.click();
    });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'screenshots/visual-audit/02_all_games.png', fullPage: true });

    // 3. Categories (go back to Home, click Categories See All)
    console.log('Navigating to Categories...');
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const tab = items.find(el => el.textContent && el.textContent.trim() === 'Home');
      if (tab) tab.click();
    });
    await page.waitForTimeout(1500);
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const seeAll = items.find(el => el.textContent && el.textContent.trim() === 'See All');
      if (seeAll) seeAll.click();
    });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'screenshots/visual-audit/03_categories.png', fullPage: true });

    // 4. Game Details (go back to Home, click ArrowBox feature banner)
    console.log('Navigating to Game Details...');
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const tab = items.find(el => el.textContent && el.textContent.trim() === 'Home');
      if (tab) tab.click();
    });
    await page.waitForTimeout(1500);
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const banner = items.find(el => el.textContent && el.textContent.includes('ArrowBox'));
      if (banner) banner.click();
    });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'screenshots/visual-audit/04_game_details.png', fullPage: true });

    // 5. ArrowBox Gameplay (click Play Now)
    console.log('Playing ArrowBox...');
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const play = items.find(el => el.textContent && el.textContent.trim() === 'Play Now');
      if (play) play.click();
    });
    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'screenshots/visual-audit/08_arrowbox.png', fullPage: true });

    // 6. Favorites Tab
    console.log('Navigating to Favorites...');
    // Click bottom nav favorites
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const tab = items.find(el => el.textContent && el.textContent.trim() === 'Favorites');
      if (tab) tab.click();
    });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'screenshots/visual-audit/06_favorites.png', fullPage: true });

    // 7. Settings Tab
    console.log('Navigating to Settings...');
    await page.evaluate(() => {
      const items = Array.from(document.querySelectorAll('flt-semantics, button, div, span'));
      const tab = items.find(el => el.textContent && el.textContent.trim() === 'Settings');
      if (tab) tab.click();
    });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'screenshots/visual-audit/07_settings.png', fullPage: true });

    console.log('All screenshots captured successfully!');
  } catch (err) {
    console.error('Error during capture:', err);
  } finally {
    await browser.close();
    server.close();
  }
}

run();
