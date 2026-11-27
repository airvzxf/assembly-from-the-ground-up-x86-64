# Assembly from the Ground Up: x86-64 Edition

An updated Linux edition of [_Programming from the Ground Up_](https://savannah.nongnu.org/projects/pgubook) by Jonathan Bartlett, maintained by Israel Roldan (AirvZxf).

- This is the **x86-64 edition**, for 64-bit Linux programs: AT&T syntax with the GNU Assembler, the `syscall` instruction and the System V AMD64 calling convention. It started from version 3.0 of the [x86 32-bit edition](https://github.com/airvzxf/assembly-from-the-ground-up-x86-32) ([asm32.rovisoft.net](https://asm32.rovisoft.net/)), but it is a new book: every chapter, appendix and example was rewritten for 64-bit Linux, with comparisons with Rust and Python, and every example program is assembled, linked and tested by `src/resource/asm/make.bash` and `test.bash`. `PORTING.md` records the decisions.
- Read online and download the PDF and ePUB: <https://asm64.rovisoft.net/>
- Downloads for every version: [GitHub releases](https://github.com/airvzxf/assembly-from-the-ground-up-x86-64/releases).

## Build

The book is a [Quarto](https://quarto.org/) book project in `src/`: one Markdown file (`.qmd`) per chapter and appendix, listed in `src/_quarto.yml`. Quarto (which includes Pandoc and [Typst](https://typst.app/)) builds the website (one page per chapter, with search), the PDF and the ePUB. The pinned version is in `scripts/install-deps.bash`.

```bash
podman build -t pgu-book .                 # or docker
podman run --rm -v "$PWD:/data:Z" pgu-book -c 'bash src/make.bash'
podman run --rm -v "$PWD:/data:Z" pgu-book -c 'bash src/resource/asm/make.bash && bash src/resource/asm/test.bash'
```

A code block shows a part of an example source with `snippet=<name>` instead of line numbers; `src/resource/asm/snippets.lua` gives each name a file and the text of its first and last line, so a snippet follows its code when the file changes, and the build fails if the text is not found.

The container also has the tools of the examples: Rust (pinned like Quarto), GTK 4 and PyGObject for Appendix A, and Xvfb and xdotool to test the GUI example without a screen.

The output is in `release/latest/`: the PDF, the ePUB, `resource.zip` with the example programs, and `site/`, the website. To preview the website while you write, run `quarto preview` in `src/`.

The website is published by the Cloudflare Pages project `assembly-from-the-ground-up-x86-64`, connected to this repository: every push to `main` builds it with `bash scripts/cloudflare-build.bash` (output directory `release/latest/site`), and every pull request gets a preview deployment.

## License

- **The book** (the `.qmd` files in `src/` and the editions built from them) is a Modified Version of _Programming from the Ground Up_, so it stays under the [GNU Free Documentation License, Version 1.1](LICENSE-GFDL-1.1.txt) or any later version, with no Invariant Sections, no Front-Cover Texts and no Back-Cover Texts. The GFDL requires the modified book to use that same license.
- **The code of this repository** (build scripts, Pandoc filters and templates, and the example programs) is under the [GNU Affero General Public License v3.0](LICENSE). The original author also grants full rights to use the book's code examples for any purpose.

## About this project.

I wanted to learn the GNU Assembler (`as` or `gas`), and I didn't find many resources, but this book is great.

The x86-64 edition of `Programming from the ground up` is complete.

Goals:

- [ ] Programming from the ground up.
  - [x] Convert the original _DocBook_ to _Markdown_ with [pandoc](https://pandoc.org/). The book is now built with [Quarto](https://quarto.org/) as a website, an _ePUB_ and a _PDF_ (_MOBI_ is obsolete: Kindle reads _ePUB_).
  - [ ] Improve and update the sections where I am missing.
  - [ ] Try to fix the [bugs](https://savannah.nongnu.org/bugs/?group=pgubook) and [support tickets](https://savannah.nongnu.org/support/?group=pgubook), since 2004 is not updated this [book](https://savannah.nongnu.org/projects/pgubook).
- [ ] Programming under the hood (another book by Jonathan Bartlett, see below).
  - [ ] Convert the original _LaTeX_ to _Markdown_ with [pandoc](https://pandoc.org/).
- [ ] Final version.
  - [x] Create a version for x64 architecture.
- [ ] ~~Create my own book from scratch, based on the experience that I gained in this project, in a new GitHub repository.~~ Dropped.

You're able to find my documents about assembly in my GitHub repository [airvzxf/assembly](https://github.com/airvzxf/assembly) also I was working in some assembler scripts that I wrote based on the [exercises of this book](https://github.com/airvzxf/assembly/tree/master/linux/gas/programmingGroundUp). It contains a Linux shell script to make all the binaries straightforward.

### Motivations.
My motivations for this project are in [Appendix J](https://asm64.rovisoft.net/appendix-j-updated-by-airvzxf) of the book.

### First steps: Programming from the ground up.
- [x] Download the original source code.
- [x] Figured out how to compile the source code.
  - [x] It's not easy: it needs some packages, and I couldn't compile the book. Another reason is that DSSSL is an old technology.
- [x] Make decisions if keeps this format or use other tools/format.
  - [x] Use `pandoc` ([official project](https://pandoc.org/)) to convert the original DocBook to Markdown format.
    - [x] Fix all the conversion failures.
      - [x] Footnotes needs to create a new numeration.
      - [x] Internal broken links for references.
      - [x] Styles and formats.
      - [x] Create a ToC (Table of contents).
    - [x] Export to the final version to ePUB.
    - [ ] ~~Export to the final version to MOBI for Kindle.~~ Obsolete: Kindle reads ePUB.
- [x] Start with the [TO-DO's file](TODO.md).

## About the original books.

### Important notes.
- This book is under the “GNU Free Documentation License”. The modified version is named _Assembly from the Ground Up: x86-64 Edition_ because the license requires a title distinct from the original.

### Original source: Programming from the ground up.
- Title: Programming from the Ground Up
- Author: Jonathan Bartlett
- Editor: Dominick Bruno, Jr.
- Copyright: © 2003 by Jonathan Bartlett
- License: GNU Free Documentation License, Version 1.1 or any later version published
- License link: [https://www.gnu.org/licenses/licenses.html#FDL](https://www.gnu.org/licenses/licenses.html#FDL)
- Resource page: [https://savannah.nongnu.org/projects/pgubook](https://savannah.nongnu.org/projects/pgubook)
- Source code: [https://savannah.nongnu.org/cvs/?group=pgubook](https://savannah.nongnu.org/cvs/?group=pgubook)

### Original source: Programming under the hood.
- Title: Programming under the hood
- Author: Jonathan Bartlett
- Copyright: © 2017 Jonathan Bartlett
- License: GNU Free Documentation License
- License link: [https://www.gnu.org/copyleft/](https://www.gnu.org/copyleft/)
- Source code: [https://github.com/johnnyb/programming_under_the_hood](https://github.com/johnnyb/programming_under_the_hood)


