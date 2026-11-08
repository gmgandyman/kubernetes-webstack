# Gateway API + Routing
This appears to be a fancy reverse-proxy ingress controller for k8s. My experience with this in VM fleets is to run Nginx as
a dumb SNI (L4) router, so not TLS certs on the ingress controller. 

## Options
1. Envoy
2. Istio
3. Cilium
4. F5 Nginx

## Decision
Envoy

## Why
Lightest weight solution with TLSRoute routing and Prometheus metrics support

## Why not X
### Istio
Sidecar required for TLSRoute

### Cilium
Requires swapping out Flannel CNI for Cilium, not interested at this time

### F5 Nginx
Sidecar required for Prometheus