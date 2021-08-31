all: out.pdf out.html out.odt

out.pdf: main.md cover.pdf template.tex
	pandoc --template=template.tex --pdf-engine=xelatex --toc --toc-depth=2 --top-level-division=chapter -V colorlinks=true \
-V linkcolor=blue \
-V urlcolor=blue \
-V toccolor=blue -o out_orig.pdf main.md
	pdftk out_orig.pdf cat 3-end output out_orig_2.pdf
	mv out_orig_2.pdf out_orig.pdf
	pdftk cover.pdf out_orig.pdf cat output out.pdf
	$(RM) out_orig*.pdf

out.tex: main.md template.tex
	pandoc -s --pdf-engine=xelatex --toc --top-level-division=chapter --toc-depth=2 -V colorlinks=true \
-V linkcolor=blue \
-V urlcolor=red \
-V toccolor=blue -o out.tex main.md

out.html: main.md
	pandoc --toc -s -c pandoc.css --to=html5 -o out.html --metadata title="Faculty Handbook" main.md

out.docx: main.md
	pandoc --toc --top-level-division=chapter -o out.docx main.md


out.odt: main.md
	pandoc  --toc -o out.odt main.md

.PHONY: clean

clean:
	$(RM) out.html out.pdf
