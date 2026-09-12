# Custom Jellyfin v12

Custom Jellyfin image based on the official Jellyfin image.

Included changes:

- Restores one-click Web login for visible passwordless users.
- Enables library backdrops by default while preserving users' explicit choices.
- Synchronizes `EnableAutoLogin` from the actual Jellyfin password state at server startup.

## Image

GitHub Actions publishes the image to:

```text
ghcr.io/aaemon/cusom-jellyfin-v12:<jellyfin-version>
ghcr.io/aaemon/cusom-jellyfin-v12:latest
```

The workflow checks `ghcr.io/jellyfin/jellyfin:latest` every six hours. It builds
and publishes only when the upstream Jellyfin version has not already been
published. The upstream version is used unchanged, matching the official
Jellyfin Docker tag format (`12.0`, not `12.0.0`). A build fails safely if
Jellyfin changes its web bundle enough that a patch is no longer valid.

## Docker Compose

```yaml
services:
  jellyfin:
    image: ghcr.io/aaemon/cusom-jellyfin-v12:12.0
```

Pin a version in production. Do not use `latest` for an unattended database
upgrade.

## Local build

```bash
docker build -t custom-jellyfin:local .
```
