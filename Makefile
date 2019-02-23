all: out.pdf out.html

out.pdf: main.md
	pandoc -o out.pdf main.md

out.html: main.md header.html footer.html
	pandoc -B header.html -A footer.html --toc --to=html5 -o out.html --metadata title="Faculty Handbook" main.md

.PHONY: clean

clean:
	$(RM) out.html out.pdf
