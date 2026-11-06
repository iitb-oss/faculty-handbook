# post-render SEO and LLM fixes; Quarto emits no og:url
import datetime, os, pathlib, re
from html import unescape

SITE = "https://iitb-oss.github.io/faculty-handbook/"
out = pathlib.Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "docs"))
DESC = re.compile(r'<meta name="description" content="([^"]*)">')

def page_url(stem):
    return SITE + ("" if stem == "index" else f"{stem}.html")

for page in out.glob("*.html"):
    if page.name.startswith("google"):  # Search Console token; must stay byte-exact
        continue
    html = page.read_text(encoding="utf-8")
    if 'rel="canonical"' in html:
        continue
    # social cards otherwise get the book-wide description
    desc = DESC.search(html)
    if desc:
        html = re.sub(r'(<meta (?:property="og|name="twitter):description" content=")[^"]*"',
                      lambda m: m.group(1) + desc.group(1) + '"', html)
    # drop chapter numbers from search-result titles
    html = re.sub(r'(<title>|(?:og|twitter):title" content=")\d+&nbsp; ', r"\1", html)
    # the JSON-LD include is static; a render happens on every push
    html = re.sub(r'"dateModified": "[^"]*"',
                  f'"dateModified": "{datetime.date.today():%Y-%m}"', html)
    url = page_url(page.stem)
    tags = f'<link rel="canonical" href="{url}">\n<meta property="og:url" content="{url}">\n'
    if (out / f"{page.stem}.llms.md").exists():
        tags += f'<link rel="alternate" type="text/markdown" href="{SITE}{page.stem}.llms.md">\n'
    html, n = re.subn(r"</head>", tags + "</head>", html, count=1)
    if n:
        page.write_text(html, encoding="utf-8")

for md in out.glob("*.llms.md"):  # pandoc appends table classes to captions
    md.write_text(re.sub(r" \{(?:\.[\w-]+ ?)+\}$", "", md.read_text(encoding="utf-8"), flags=re.M),
                  encoding="utf-8")

def description(stem):
    m = DESC.search((out / f"{stem}.html").read_text(encoding="utf-8"))
    return unescape(m.group(1)) if m else ""

# Quarto's llms.txt keeps pandoc attributes in titles and has no descriptions
llms = out / "llms.txt"
if llms.exists():
    text = llms.read_text(encoding="utf-8")
    lines, full = [], []
    for title, stem in re.findall(rf"^- \[(.*)\]\({re.escape(SITE)}([\w-]+)\.llms\.md\)(?:: .*)?$", text, re.M):
        m = re.search(r"\[([^\]]*)\]\{\.chapter-title\}", title)
        title = m.group(1) if m else title
        lines.append(f"- [{title}]({SITE}{stem}.llms.md): {description(stem)}")
        full.append(f"<!-- Source: {page_url(stem)} -->\n\n"
                    + (out / f"{stem}.llms.md").read_text(encoding="utf-8").strip())
    assert lines, "no pages found in llms.txt"
    llms.write_text(f"""{text.splitlines()[0]}

> {description("index")}

Rules and rates change, so check the circular cited in each chapter. Report errors at https://github.com/iitb-oss/faculty-handbook/issues

- [Full text as one Markdown file]({SITE}llms-full.txt)
- [PDF]({SITE}IITB-Faculty-Handbook.pdf)

## Chapters

""" + "\n".join(lines) + "\n", encoding="utf-8")
    (out / "llms-full.txt").write_text("\n\n---\n\n".join(full) + "\n", encoding="utf-8")
