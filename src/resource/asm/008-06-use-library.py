# PURPOSE:
#     Call the assembly functions `count_chars` and
#     `call_count` of the shared library `libbook.so`
#     from Python, with the ctypes module.
#
# Run in the directory of libbook.so:
#     python3 008-06-use-library.py

import ctypes
import os

library = ctypes.CDLL(os.path.abspath("libbook.so"))

# ctypes can't read the library's types: describe the
# parameters and the result of each function.
library.count_chars.argtypes = [ctypes.c_char_p]
library.count_chars.restype = ctypes.c_uint64
library.call_count.argtypes = []
library.call_count.restype = ctypes.c_uint64

length = library.count_chars(b"hello world")
print(f'count_chars("hello world") = {length}')

for _ in range(3):
    print(f"call_count() = {library.call_count()}")
