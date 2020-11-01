all: out.pdf out.html out.odt

out.pdf: main.md
	pandoc --pdf-engine=xelatex --toc --top-level-division=chapter -o out.pdf main.md

out.html: main.md
	pandoc --number-sections --toc -s -c pandoc.css --to=html5 -o out.html --metadata title="Faculty Handbook" main.md

out.docx: main.md
	pandoc  --number-sections --toc -o out.docx main.md

out.odt: main.md
	pandoc  --number-sections --toc -o out.odt main.md

.PHONY: clean

clean:
	$(RM) out.html out.pdf
