# Temporary 32-bit copies

The 32-bit versions of example files that are already written for
x86-64, kept only because some 32-bit programs of later chapters still
use them. `make.bash` assembles the 32-bit sources from inside this
directory, so their `.include "006-01-linux.s"` finds the 32-bit copy
here. Each chapter that is written for x86-64 removes what it no longer
needs, and the close-out of `PORTING.md` deletes this directory. It is
not part of the book or of `resource.zip`.
