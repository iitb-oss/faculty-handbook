all: out.pdf out.html

out.pdf: main.md
	pandoc --toc --top-level-division=chapter -o out.pdf main.md

out.html: main.md
	pandoc --number-sections --toc -s -c pandoc.css --to=html5 -o out.html --metadata title="Faculty Handbook" main.md

.PHONY: clean

clean:
	$(RM) out.html out.pdf
