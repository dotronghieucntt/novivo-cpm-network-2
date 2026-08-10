from playwright.sync_api import sync_playwright

url = 'http://localhost:3015/admin/tracking/conversions'
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    for name, size in [('desktop', {'width': 1440, 'height': 1000}), ('mobile', {'width': 390, 'height': 844})]:
        page = browser.new_page(viewport=size)
        errors = []
        page.on('console', lambda msg: errors.append(f'{msg.type}: {msg.text}') if msg.type in ['error', 'warning'] else None)
        resp = page.goto(url, wait_until='networkidle', timeout=60000)
        print(f'VIEW={name} STATUS={resp.status if resp else "none"} URL={page.url}')
        print('TITLE=', page.title())
        print('BODY_SNIPPET=', page.locator('body').inner_text(timeout=10000)[:1200].replace('\n', ' | '))
        print('BUTTONS=', [b.inner_text() for b in page.locator('button').all()[:20]])
        print('INPUTS=', page.locator('input, select, textarea').count())
        print('CONSOLE=', errors[:10])
        page.screenshot(path=f'C:/Users/ADMIN/Desktop/NOVIVO CPM NETWORK 2/{name}-conversions.png', full_page=True)
        page.close()
    browser.close()
