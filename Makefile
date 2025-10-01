QUARTO = quarto
PDFTK = pdftk
RM = rm -f

QMD_FILES = $(wildcard *.qmd)
MAIN_CONFIG = _quarto.yml
COVER_PDF = cover.pdf
TEMPLATE = template.tex

OUT_PDF = IITB-Faculty-Handbook.pdf
OUT_HTML = out.html
FACULTY_PDF = docs/Faculty-Handbook.pdf
DOCS_HTML = docs/index.html

all: $(OUT_PDF) $(OUT_HTML)
	@echo "Copying final PDF to docs directory..."
	cp $(OUT_PDF) docs/$(OUT_PDF)
	@echo "Build complete: $(OUT_PDF) and $(OUT_HTML)"

$(OUT_PDF): $(QMD_FILES) $(MAIN_CONFIG) $(COVER_PDF) $(TEMPLATE)
	@echo "Building Quarto PDF..."
	$(QUARTO) render --to pdf
	@echo "Processing PDF with cover..."
	cp $(FACULTY_PDF) out_orig.pdf
	$(PDFTK) out_orig.pdf cat 3-end output out_orig_2.pdf
	mv out_orig_2.pdf out_orig.pdf
	$(PDFTK) $(COVER_PDF) out_orig.pdf cat output $(OUT_PDF)
	$(RM) out_orig*.pdf
	@echo "PDF build complete: $(OUT_PDF)"

$(OUT_HTML): $(QMD_FILES) $(MAIN_CONFIG)
	@echo "Building Quarto HTML..."
	$(QUARTO) render --to html
	cp $(DOCS_HTML) $(OUT_HTML)
	@echo "HTML build complete: $(OUT_HTML)"

pdf: $(QMD_FILES) $(MAIN_CONFIG) $(TEMPLATE)
	@echo "Building PDF without cover..."
	$(QUARTO) render --to pdf
	cp $(FACULTY_PDF) Faculty-Handbook-nocover.pdf
	@echo "PDF build complete: Faculty-Handbook-nocover.pdf"

html: $(QMD_FILES) $(MAIN_CONFIG)
	@echo "Building HTML only..."
	$(QUARTO) render --to html
	@echo "HTML build complete in docs/"

quarto-all: $(QMD_FILES) $(MAIN_CONFIG)
	@echo "Building all Quarto formats..."
	$(QUARTO) render
	@echo "All formats built in docs/"

tex: $(QMD_FILES) $(MAIN_CONFIG) $(TEMPLATE)
	@echo "Generating LaTeX file..."
	$(QUARTO) render --to pdf --keep-tex
	@echo "LaTeX file generated: index.tex"

preview:
	@echo "Starting Quarto preview server..."
	$(QUARTO) preview

clean:
	@echo "Cleaning up generated files..."
	$(RM) $(OUT_PDF) $(OUT_HTML)
	$(RM) out_orig*.pdf Faculty-Handbook-nocover.pdf
	$(RM) -rf docs/
	$(RM) index.tex index.log index.aux index.fls index.fdb_latexmk
	@echo "Clean complete"

clean-all: clean
	@echo "Deep cleaning..."
	$(RM) -rf .quarto/
	@echo "Deep clean complete"

check-deps:
	@echo "Checking dependencies..."
	@which $(QUARTO) > /dev/null || (echo "Error: quarto not found" && exit 1)
	@which $(PDFTK) > /dev/null || (echo "Warning: pdftk not found - PDF with cover will not work")
	@test -f $(COVER_PDF) || echo "Warning: $(COVER_PDF) not found - PDF with cover will not work"
	@test -f $(TEMPLATE) || echo "Warning: $(TEMPLATE) not found - using default template"
	@echo "Dependency check complete"

help:
	@echo "Available targets:"
	@echo "  all         - Build PDF with cover and HTML (default)"
	@echo "  pdf    - Build PDF without cover"
	@echo "  html   - Build HTML only"
	@echo "  quarto-all  - Build all formats using Quarto directly"
	@echo "  tex         - Generate LaTeX intermediate file"
	@echo "  preview     - Start local preview server"
	@echo "  clean       - Remove generated files"
	@echo "  clean-all   - Remove all generated and cached files"
	@echo "  check-deps  - Check for required dependencies"
	@echo "  help        - Show this help message"

.PHONY: all pdf-only html-only quarto-all tex preview clean clean-all check-deps help

