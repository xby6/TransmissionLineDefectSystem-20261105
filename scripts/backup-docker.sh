#!/usr/bin/env bash
set -euo pipefail
umask 077
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
compose=(docker compose --env-file .env.docker)
backup_dir="${1:-$project_root/tmp/docker-backups/$(date +%Y%m%d-%H%M%S)}"
mkdir -p -- "$backup_dir"
backup_dir="$(cd -- "$backup_dir" && pwd)"
for name in database.dump backend-files.tar.gz algorithm-data.tar.gz env.docker commit.txt; do
    if [[ -e "$backup_dir/$name" ]]; then
        echo "Refusing to overwrite existing backup: $backup_dir/$name" >&2
        exit 1
    fi
done

# Stop the frontend/backend and wait until algorithm jobs finish BEFORE this script.
# An existing file makes this run fail rather than replace a previous backup.
set -o noclobber
"${compose[@]}" exec -T postgres sh -c \
    'exec pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' \
    > "$backup_dir/database.dump"
"${compose[@]}" run --rm --no-deps --entrypoint tar backend \
    -C /app -czf - upload_file vf_admin \
    > "$backup_dir/backend-files.tar.gz"
tar -czf "$backup_dir/algorithm-data.tar.gz" \
    -C "$project_root/Intelligent Detection System for Transmission Line Defects-server" \
    algo model config.yaml model_config.yaml
(set -o noclobber; cat .env.docker > "$backup_dir/env.docker")
if command -v git >/dev/null 2>&1 && git rev-parse HEAD > "$backup_dir/commit.txt" 2>/dev/null; then
    :
else
    printf '%s\n' 'unknown (source export without Git metadata)' >| "$backup_dir/commit.txt"
fi
echo "Saved database, uploads, algorithms, models and credentials to: $backup_dir"
echo 'Copy this directory OFF the cloud server before releasing the server.'
