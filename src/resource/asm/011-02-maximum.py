#!/usr/bin/env python3
# PURPOSE:
#     The maximum program of Chapter 3 in Python: find
#     the largest number of a list and return it as
#     the exit status code (222).
#
# See the bytecode that Python generates:
#     python3 -m dis 011-02-maximum.py

import sys

DATA_ITEMS = [3, 67, 34, 222, 45, 22, 11, 125]


def maximum(items):
    largest = items[0]
    for item in items[1:]:
        if item > largest:
            largest = item
    return largest


sys.exit(maximum(DATA_ITEMS))
