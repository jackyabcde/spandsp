#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

echo "==> Bootstrapping spandsp..."
cd "${REPO}"
if [ ! -f configure ] || [ "${1:-}" = "--rebootstrap" ]; then
    ./bootstrap.sh
fi

echo "==> Configuring spandsp..."
./configure --prefix="${REPO}/../install" \
    CPPFLAGS="-I${REPO}/../install/include" \
    LDFLAGS="-L${REPO}/../install/lib"

echo "==> Patching make_v34_probe_signals compile rule..."
sed -i '' \
    's|-I$(top_builddir)/src -lm|-I$(top_builddir)/src -I$(top_builddir)/../install/include -lm|' \
    src/Makefile

echo "==> Building spandsp..."
make -j"$(sysctl -n hw.ncpu)"

echo "==> Installing spandsp to ../install..."
make install

echo "==> spandsp build complete"
