// The index of the PDF (resource/pandoc/lua/index.lua marks its entries).
// Resetting the chapter counter keeps the page header of orange-book
// from naming the last appendix ("P. Index") on these pages.
#counter(heading).update(0)
#make-index(title: "Index")
