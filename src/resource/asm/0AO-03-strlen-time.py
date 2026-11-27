#!/usr/bin/env python3
# PURPOSE:
#     Time the four versions of libstrlen.so and
#     the strlen of the C library on a string of
#     one million bytes. Each one runs 200 times,
#     and the best time counts, because the others
#     include interruptions by other programs.

import ctypes
import os
import time

here = os.path.dirname(os.path.abspath(__file__))
lib = ctypes.CDLL(os.path.join(here, "libstrlen.so"))
libc = ctypes.CDLL(None)            # The C library.
names = ["strlen_v1", "strlen_v2", "strlen_v3",
         "strlen_v4"]
functions = [getattr(lib, name) for name in names]
names.append("C library")
functions.append(libc.strlen)

length = 1_000_000
text = ctypes.create_string_buffer(b"a" * length)
for name, function in zip(names, functions):
    function.argtypes = [ctypes.c_char_p]
    function.restype = ctypes.c_size_t
    best = None
    for run in range(200):
        begin = time.perf_counter_ns()
        result = function(text)
        took = time.perf_counter_ns() - begin
        if best is None or took < best:
            best = took
    assert result == length
    print(f"{name:10} {best / length:6.3f} ns/byte")
