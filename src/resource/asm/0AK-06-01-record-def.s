    # PURPOSE:
    #     Solution to Chapter 6, "Use the Concepts":
    #     the person record with a new data member,
    #     a phone number (24 bytes) after the age.
    #     24 keeps the size a multiple of 8.
    #
        .equ RECORD_FIRSTNAME,  0
        .equ RECORD_LASTNAME,   40
        .equ RECORD_ADDRESS,    80
        .equ RECORD_AGE,        320
        .equ RECORD_PHONE,      328   # New member.
        .equ RECORD_SIZE,       352   # Was 328.
