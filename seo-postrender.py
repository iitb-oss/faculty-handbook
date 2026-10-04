# post-render SEO fixes; Quarto emits no canonical link or og:url
import os, re, pathlib

SITE = "https://saket-choudhary.me/my-iitb-faculty-handbook/"
out = pathlib.Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "docs"))

for page in out.glob("*.html"):
    if page.name.startswith("google"):  # Search Console token; must stay byte-exact
        continue
    html = page.read_text(encoding="utf-8")
    if 'rel="canonical"' in html:
        continue
    # social cards otherwise get the book-wide description
    desc = re.search(r'<meta name="description" content="([^"]*)">', html)
    if desc:
        html = re.sub(r'(<meta (?:property="og|name="twitter):description" content=")[^"]*"',
                      lambda m: m.group(1) + desc.group(1) + '"', html)
    # drop chapter numbers from search-result titles
    html = re.sub(r'(<title>|(?:og|twitter):title" content=")\d+&nbsp; ', r"\1", html)
    url = SITE + ("" if page.name == "index.html" else page.name)
    tags = f'<link rel="canonical" href="{url}">\n<meta property="og:url" content="{url}">\n'
    html, n = re.subn(r"</head>", tags + "</head>", html, count=1)
    if n:
        page.write_text(html, encoding="utf-8")
