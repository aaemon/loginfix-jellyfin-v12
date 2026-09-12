ARG JELLYFIN_IMAGE=ghcr.io/jellyfin/jellyfin:latest
FROM ${JELLYFIN_IMAGE}

ARG JELLYFIN_BASE_DIGEST=unknown
LABEL org.opencontainers.image.source="https://github.com/aaemon/loginfix-jellyfin-v12"
LABEL io.raspicloud.jellyfin-autologin.base-digest="${JELLYFIN_BASE_DIGEST}"

USER root

RUN apt-get update \
    && apt-get install --no-install-recommends -y sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Jellyfin v12 no longer exposes password state to Web clients. Reuse the
# existing per-user EnableAutoLogin flag for users with no configured password.
RUN set -eu; \
    login_bundle=$(printf '%s\n' /jellyfin/jellyfin-web/session-login.*.chunk.js); \
    test -f "$login_bundle"; \
    test "$(grep -oE '[A-Za-z_$][A-Za-z0-9_$]*\.HasPassword' "$login_bundle" | wc -l)" -eq 1; \
    old_name=${login_bundle##*/}; \
    old_hash=${old_name#session-login.}; \
    old_hash=${old_hash%.chunk.js}; \
    sed -i -E 's/([A-Za-z_$][A-Za-z0-9_$]*)\.HasPassword/\1.EnableAutoLogin?!1:\1.HasPassword/' "$login_bundle"; \
    grep -qE '[A-Za-z_$][A-Za-z0-9_$]*\.EnableAutoLogin\?!1:[A-Za-z_$][A-Za-z0-9_$]*\.HasPassword' "$login_bundle"; \
    mv "$login_bundle" /jellyfin/jellyfin-web/session-login.autologin00000000000.chunk.js; \
    sed -i "s/$old_hash/autologin00000000000/g" /jellyfin/jellyfin-web/runtime.bundle.js; \
    grep -q 'autologin00000000000' /jellyfin/jellyfin-web/runtime.bundle.js; \
    sed -i -E 's/runtime\.bundle\.js\?[^" ]+/runtime.bundle.js?autologin1/g' /jellyfin/jellyfin-web/index.html; \
    grep -q 'runtime.bundle.js?autologin1' /jellyfin/jellyfin-web/index.html

COPY jellyfin-wrapper.sh /usr/local/bin/jellyfin-autologin-wrapper

# This works even when a Compose deployment supplies its own entrypoint.
RUN mv /jellyfin/jellyfin /jellyfin/jellyfin.real \
    && mv /usr/local/bin/jellyfin-autologin-wrapper /jellyfin/jellyfin \
    && chmod 755 /jellyfin/jellyfin
