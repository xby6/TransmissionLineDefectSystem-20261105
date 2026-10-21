#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if ! docker info >/dev/null 2>&1; then
    echo 'Docker Engine is unavailable. Start Docker and check your user permissions.' >&2
    exit 1
fi
docker compose version
if [[ ! -f .env.docker ]]; then
    python3 scripts/configure_docker.py
fi
compose=(docker compose --env-file .env.docker)
"${compose[@]}" config --quiet
# Build sequentially to reduce peak memory on a 4-vCPU / 8-GB machine.
"${compose[@]}" build algo-server
"${compose[@]}" build backend
"${compose[@]}" build frontend
"${compose[@]}" up -d --wait --wait-timeout 300
"${compose[@]}" ps
echo 'Deployment started. Visit http://<server-public-IP>:<HTTP_PORT>/index'
echo 'Initial account: admin. Read ADMIN_PASSWORD in .env.docker locally.'
