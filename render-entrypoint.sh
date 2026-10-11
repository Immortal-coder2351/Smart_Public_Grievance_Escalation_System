#!/bin/sh
set -eu

PORT="${PORT:-10000}"
sed -i "s/port=\"8080\"/port=\"${PORT}\"/" "$CATALINA_HOME/conf/server.xml"

UPLOAD_DIR="${UPLOAD_DIR:-/var/data/uploads}"
export UPLOAD_DIR
mkdir -p "$UPLOAD_DIR"

BUNDLED_UPLOADS="$CATALINA_HOME/webapps/ROOT/uploads"
if [ -d "$BUNDLED_UPLOADS" ]; then
    for file in "$BUNDLED_UPLOADS"/*; do
        [ -f "$file" ] || continue
        cp -n "$file" "$UPLOAD_DIR/" 2>/dev/null || true
    done
fi

exec "$CATALINA_HOME/bin/catalina.sh" run
