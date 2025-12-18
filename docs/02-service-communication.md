# Service Communication

## Phase 1: REST (sync)
- Simple and debuggable
- Requires explicit timeouts, retries, and careful error handling

## Phase 2: gRPC (sync)
- Faster + typed contracts
- Harder debugging without tooling
- Great for internal service-to-service at scale

## Phase 3: Events (async)
- Decouples producers/consumers
- Introduces eventual consistency + idempotency

## Phase 6: Service Mesh (Istio) (optional)
Use when you need:
- mTLS everywhere
- fine-grained traffic splitting (canary/shadow)
- consistent retries/circuit breaking and telemetry

EKS makes mesh adoption straightforward; ECS can do mesh via AWS App Mesh but it’s less universal.
