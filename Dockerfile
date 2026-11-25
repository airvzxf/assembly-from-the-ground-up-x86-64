# Build environment for the book (Quarto), the assembly examples, Rust
# (Chapter 8) and the 32-bit examples (gcc-multilib). Versions are pinned
# in scripts/install-deps.bash.
#
#   podman build -t pgu-book .
#   podman run --rm -v "$PWD:/data:Z" pgu-book -c 'bash src/make.bash'
FROM ubuntu:24.04

COPY scripts/install-deps.bash /tmp/install-deps.bash
RUN bash /tmp/install-deps.bash && rm /tmp/install-deps.bash

WORKDIR /data

ENTRYPOINT ["/usr/bin/env", "bash"]
