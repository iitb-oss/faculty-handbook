# IIT Bombay Faculty Handbook

This repository contains the IIT Bombay Faculty Handbook built with Quarto.
https://iitb-oss.github.io/faculty-handbook/

## Features

- **Modern Web Interface**: Responsive HTML book with navigation and search
- **PDF Download**: Professional A5-format PDF with original styling preserved
- **GitHub Pages Deployment**: Automatically deployed on push
- **Original Layout**: Maintains the exact typography and layout from the original handbook

## Building the Handbook

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (version 1.3 or later)
- XeLaTeX (for PDF generation)
- pdftk (optional, for adding cover to PDF)

### Install Fonts

The handbook uses specific fonts for proper rendering:

```bash
./install-fonts.sh
```

This script will install:
- Arial (or Liberation Sans as fallback on Linux)
- Ubuntu fonts
- Latin Modern fonts

### Build Commands

#### Using Quarto directly:

```bash
# Build both HTML and PDF
quarto render

# Build HTML only
quarto render --to html

# Build PDF only
quarto render --to pdf
```

#### Using Make:

```bash
# Build everything (including PDF with cover)
make -f Makefile.quarto all

# Build PDF without cover
make -f Makefile.quarto pdf-only

# Build HTML only
make -f Makefile.quarto html-only

# Preview locally
make -f Makefile.quarto preview

# Clean generated files
make -f Makefile.quarto clean

# Show all available targets
make -f Makefile.quarto help
```

### Output Files

- `docs/index.html` - Main HTML handbook
- `docs/IITB-Faculty-Handbook.pdf` - Downloadable PDF for web (with cover)
- `IITB-Faculty-Handbook.pdf` - PDF with cover (when using `make all`)
- `out.html` - Standalone HTML file

## Project Structure

```
├── _quarto.yml              # Quarto configuration
├── *.qmd                    # Individual chapter files
├── template.tex             # LaTeX template for PDF
├── cover.pdf                # Cover page for PDF
├── custom.scss              # Custom styling for HTML
├── styles.css               # Additional CSS styles
├── install-fonts.sh         # Font installation script
├── Makefile.quarto          # Build automation
└── .github/workflows/       # CI/CD configuration
    └── quarto-publish.yml   # GitHub Actions workflow
```

## GitHub Actions / CI

The handbook automatically builds and deploys on push to the `quarto`, `main`, or `master` branches.

The CI workflow:
1. Installs Microsoft Core Fonts (including Arial) via `ttf-mscorefonts-installer`
2. Installs Liberation fonts as fallback
3. Runs the font installation script for Ubuntu and Latin Modern fonts
4. Refreshes font cache
5. Builds both HTML and PDF versions
6. Deploys to GitHub Pages

### Font Handling in CI

The workflow installs multiple font families for proper rendering:
- **Arial**: Installed via `ttf-mscorefonts-installer` package (main text)
- **Noto Sans**: Installed via `fonts-noto` package (for special characters like ₹)
- **Liberation Sans**: Installed as fallback (metric-compatible with Arial)
- **DejaVu fonts**: Installed for Unicode coverage
- **Ubuntu fonts**: Installed via custom script
- **Latin Modern fonts**: Installed via custom script

**Special Character Handling:**
The rupee symbol (₹) and other Unicode characters are rendered using Noto Sans font, which has comprehensive Unicode coverage. This ensures special characters display correctly even when the main font (Arial) doesn't support them.

## Configuration Details

### PDF Settings (matching original pandoc build)

- **Document Class**: `amsbook`
- **Paper Size**: A5
- **Margins**: 0.4in (left/right), 1in (top/bottom)
- **PDF Engine**: XeLaTeX
- **TOC Depth**: 2
- **Fonts**: Arial with Liberation Sans fallback
- **Links**: Blue colored links throughout

### HTML Settings

- **Theme**: Cosmo with custom styling
- **Font**: Arial (system font) with Noto Sans for Unicode characters
- **Responsive**: Mobile-friendly design
- **Navigation**: Sidebar with chapter navigation
- **Search**: Full-text search functionality
- **Download**: Prominent PDF download button
- **Unicode Support**: Rupee symbol (₹) and special characters rendered via Noto Sans fallback

## Development

### Preview Changes Locally

```bash
quarto preview
```

This starts a local server (usually at http://localhost:4200) with live reload.

### Updating Content

1. Edit the relevant `.qmd` files
2. Run `quarto render` to rebuild
3. Check the output in `docs/` directory
4. Commit and push to trigger automatic deployment

### Adding New Chapters

1. Create a new `.qmd` file
2. Add it to the `chapters` list in `_quarto.yml`
3. Rebuild with `quarto render`

## Troubleshooting

### Font Issues

If you see font-related errors:

1. Run `./install-fonts.sh` to ensure fonts are installed
2. Refresh font cache: `fc-cache -f -v`
3. Verify fonts are available: `fc-list | grep -i "times\|ubuntu\|lm"`

### PDF Build Failures

If PDF generation fails:

1. Check that XeLaTeX is installed: `xelatex --version`
2. Check the LaTeX log: `cat index.log`
3. Try building with `--keep-tex` to debug: `quarto render --to pdf --keep-tex`

### GitHub Actions Failures

If the CI build fails:

1. Check the Actions tab on GitHub for detailed logs
2. Look for font-related errors in the "Install fonts" step
3. Verify the font installation script ran successfully
4. Check that all `.qmd` files are valid

## Original Build System

The original handbook was built using pandoc directly. The settings have been preserved in the Quarto configuration:

```bash
# Original pandoc command (for reference)
pandoc --template=template.tex --pdf-engine=xelatex --toc --toc-depth=2 \
  --top-level-division=chapter -V colorlinks=true \
  -V linkcolor=blue -V urlcolor=blue -V toccolor=blue \
  -o out.pdf main.md
```

All these settings are now configured in `_quarto.yml` and produce an identical PDF output.

## License

This handbook is maintained by IIT Bombay for the benefit of its faculty members.

## Contact

For questions or updates, please contact the Dean (Faculty Affairs) office at IIT Bombay.
