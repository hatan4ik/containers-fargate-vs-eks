# Lab 01 — Local Containers

Goal: run `gateway → orders → users` locally and validate sync communication.

## Run
```bash
./scripts/up.sh
./scripts/smoke.sh
```

## Exercises
- Add artificial latency to `users` and observe failures
- Tune timeouts between services (see `services/orders` and `services/gateway`)
