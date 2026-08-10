from playwright.sync_api import sync_playwright

urls = [
    ("home", "http://localhost:3015"),
    ("admin", "http://localhost:3015/admin/dashboard"),
    ("login", "http://localhost:3015/login"),
]

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1366, "height": 900})
    errors = []
    page.on("console", lambda msg: errors.append(f"console:{msg.type}:{msg.text}"))
    page.on("pageerror", lambda exc: errors.append(f"pageerror:{exc}"))

    for name, url in urls:
        try:
            response = page.goto(url, wait_until="networkidle", timeout=90000)
            title = page.title()
            body = page.locator("body").inner_text(timeout=10000)
            print(f"=== {name} ===")
            print(f"url={page.url}")
            print(f"status={response.status if response else 'no-response'}")
            print(f"title={title}")
            print(f"body_preview={body[:500].replace(chr(10), ' | ')}")
            page.screenshot(path=f"c:/Users/ADMIN/Desktop/NOVIVO CPM NETWORK 2/{name}.png", full_page=True)
        except Exception as exc:
            print(f"=== {name} ===")
            print(f"error={type(exc).__name__}: {exc}")

    if errors:
        print("=== browser_errors ===")
        for error in errors[:50]:
            print(error)
    browser.close()
