#!/usr/bin/env bash
set -euo pipefail
docker compose up --build -d
echo "Up. Try: curl -s localhost:3000/healthz | jq"