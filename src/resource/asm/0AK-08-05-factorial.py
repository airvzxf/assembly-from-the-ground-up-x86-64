# PURPOSE:
#     Solution to Chapter 8, "Use the Concepts":
#     call the assembly function `factorial` of
#     `libfactorial.so` from Python, with ctypes.
#
# Run in the directory of libfactorial.so:
#     python3 0AK-08-05-factorial.py

import ctypes
import os

path = os.path.abspath("libfactorial.so")
factorial = ctypes.CDLL(path).factorial
factorial.argtypes = [ctypes.c_int64]
factorial.restype = ctypes.c_int64

for n in (5, 10, 20, 21):
    print(f"{n}! = {factorial(n)}")
