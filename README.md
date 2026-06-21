# macs-test-suite

A minimal sentinel container for testing [mqdockerup](https://github.com/MacLeod92/mqdockerup) and its companion Compose sidecar, [mqdockerup-compose](https://github.com/MacLeod92/mqdockerup-compose).

Sits in a compose stack, exposes a `/health` endpoint, and can be trivially updated (bump `VERSION`) to produce a new image SHA — giving mqdockerup something to detect. Will likely grow to cover other test scenarios over time.

## Usage

```yaml
services:
  macs-test-suite:
    image: ghcr.io/macleod92/macs-test-suite:latest
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
```

Other services can depend on it:

```yaml
  my-app:
    image: ...
    depends_on:
      macs-test-suite:
        condition: service_healthy
```

## Forcing a new SHA (triggering an update)

1. Edit `VERSION` — increment to e.g. `0.1.1`
2. Commit and push to `main`
3. CI builds and pushes a new image to GHCR, changing the SHA
4. mqdockerup detects the drift and offers an update

```bash
echo "0.1.1" > VERSION
git add VERSION
git commit -m "chore: bump version to 0.1.1"
git push origin main
```

## Healthcheck response
GET /health → 200 OK

{"status":"ok","version":"0.1.0"}

## CI / Publishing

Images are built and published to [GitHub Container Registry](https://ghcr.io) automatically on every push to `main` via the workflow in `.github/workflows/build.yml`.

No manual registry login or secrets setup is required — GitHub Actions provides a built-in `GITHUB_TOKEN` with package-write permissions for this repo.

After the first successful build, confirm the package visibility is set to **Public** under your GitHub profile → **Packages** → `macs-test-suite` → **Package settings**, so it can be pulled without authentication.

## Pulling the image

```bash
docker pull ghcr.io/macleod92/macs-test-suite:latest
```

## First push (maintainer notes)

```bash
cd /opt/github.com/macs-test-suite
git init
git remote add origin git@github.com:MacLeod92/macs-test-suite.git
git add .
git commit -m "feat: initial sentinel image"
git push -u origin main
```