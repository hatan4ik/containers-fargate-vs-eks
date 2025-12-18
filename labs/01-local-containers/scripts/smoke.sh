#!/usr/bin/env bash
set -euo pipefail

curl -sf localhost:3000/healthz >/dev/null && echo "gateway ok"
curl -sf localhost:3001/healthz >/dev/null && echo "users ok"
curl -sf localhost:3002/healthz >/dev/null && echo "orders ok"

echo "Checkout flow:"
curl -s -X POST localhost:3000/checkout \
  -H 'content-type: application/json' \
  -d '{"userId":"123","item":"demo"}' | jq .
