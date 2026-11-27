#!/usr/bin/env python3
# PURPOSE:
#     Check the four versions of libstrlen.so
#     against Python's len(): every length from
#     0 to 100 and some longer ones, starting at
#     each of the 16 positions of an aligned block.

import ctypes
import os
import sys

here = os.path.dirname(os.path.abspath(__file__))
lib = ctypes.CDLL(os.path.join(here, "libstrlen.so"))
names = ["strlen_v1", "strlen_v2", "strlen_v3",
         "strlen_v4"]
functions = []
for name in names:
    function = getattr(lib, name)
    function.argtypes = [ctypes.c_void_p]
    function.restype = ctypes.c_size_t
    functions.append(function)

lengths = list(range(101)) + [255, 256, 4095,
                              4096, 4097, 70000]
# 16 extra bytes before the string, to move its
# start, and the null byte after it.
size = max(lengths) + 32
buffer = ctypes.create_string_buffer(size + 16)
start = ctypes.addressof(buffer)
start += -start % 16            # Align to 16.
errors = 0
for length in lengths:
    for offset in range(16):
        ctypes.memset(start, ord("a"), size - 16)
        ctypes.memset(start + offset + length, 0, 1)
        for name, function in zip(names, functions):
            if function(start + offset) != length:
                print(f"{name}: wrong length for "
                      f"{length} at offset {offset}")
                errors += 1

print("errors:", errors)
sys.exit(1 if errors else 0)
