#!/usr/bin/env python3
# PURPOSE:
#     Solution to Chapter 11, "Use the Concepts":
#     `005-01-toupper` in Python. It converts a file
#     to uppercase.
#
# USAGE:
#     python3 0AK-11-01-toupper.py input.txt output.txt

import sys

if len(sys.argv) != 3:
    sys.exit("Usage: toupper input output")

try:
    with open(sys.argv[1], "rb") as source:
        text = source.read()
    with open(sys.argv[2], "wb") as target:
        target.write(text.upper())
except OSError as error:
    sys.exit(f"Error: {error}")
