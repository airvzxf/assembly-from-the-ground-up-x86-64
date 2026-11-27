# Build environment for the book (Quarto), the assembly examples, Rust
# (Chapters 8 and 11) and GTK 4 with Xvfb (Appendix A). Versions are
# pinned in scripts/install-deps.bash.
#
#   podman build -t pgu-book .
#   podman run --rm -v "$PWD:/data:Z" pgu-book -c 'bash src/make.bash'
#
# scripts/check-outputs.py also needs `--security-opt seccomp=unconfined`
# for its `setarch -R` check (see README.md).
FROM ubuntu:24.04

COPY scripts/install-deps.bash /tmp/install-deps.bash
RUN bash /tmp/install-deps.bash && rm /tmp/install-deps.bash

WORKDIR /data

ENTRYPOINT ["/usr/bin/env", "bash"]
