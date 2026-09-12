#!/bin/sh
set -eu

database=/config/data/jellyfin.db
if [ -f "$database" ]; then
    if ! sqlite3 "$database" \
        'UPDATE Users SET EnableAutoLogin = CASE WHEN Password IS NULL OR Password = "" THEN 1 ELSE 0 END;'; then
        echo "[autologin] WARNING: Could not synchronize passwordless users." >&2
    fi
fi

exec /jellyfin/jellyfin.real "$@"
