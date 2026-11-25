    # ----- Common Linux Definitions ----- #
    #
    # System Call Numbers.
    #
        .equ SYS_READ,       0
        .equ SYS_WRITE,      1
        .equ SYS_CLOSE,      3
        .equ SYS_LSEEK,      8
        .equ SYS_BRK,        12
        .equ SYS_EXIT,       60
        .equ SYS_OPENAT,     257

    # Directory for openat: the current directory.
    #
        .equ AT_FDCWD,       -100

    # Options for openat.
    #
        .equ O_RDONLY,              0
        .equ O_RDWR,                02
        .equ O_CREAT_WRONLY_TRUNC,  01101

    # Standard File Descriptors.
    #
        .equ STDIN,          0
        .equ STDOUT,         1
        .equ STDERR,         2

    # Common Status Codes.
    #
        .equ END_OF_FILE,    0
