# Debug (EKS)

- `kubectl describe pod`
- `kubectl logs`
- check readiness/liveness
- check Service selectors and ports
- check `kubectl -n z2h describe networkpolicy` and VPC CNI network-policy logs
  for unexpected denied traffic
