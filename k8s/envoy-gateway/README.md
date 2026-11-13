# Envoy Gateway
Implementation of k8s Gateway API that supports TLSRoute.

There are two large sections for this:
- Gateway API
- Envoy specific

## Gateway API
This is the gateway API set of CRDs, from the experimental channel because we plan to use
TLSRoute, not just HTTPRoute.

We don't install these ourselves. The gateway-helm chart carries them in its `crds`
subchart and already ships the experimental channel - all 13 CRDs, TLSRoute included - at
the bundle version the controller in that chart was built against (v1.10.0 of the chart
bundles Gateway API v1.6.1). Installing our own copy first only breaks things: `kubectl
apply --server-side` makes `kubectl` the field-manager owner of those CRDs, and helm's
CRD install then fails with server-side apply conflicts on `.spec.versions` and the
`api-approved.kubernetes.io` / `bundle-version` annotations.

So the chart version is the only version knob - there's deliberately no
`GATEWAY_API_VERSION` in `toolbox/.env`. The chart's single `crds.enabled` value is
all-or-nothing (Gateway API CRDs, Envoy Gateway's own CRDs and the safe-upgrade policy
all live in that one subchart), so turning it off would mean installing Envoy Gateway's
CRDs by hand too.

## Envoy specific
- Envoy gateway class interface to the Gateway API
- Envoy controller
- Envoy-proxy for handling our specific configuration requirements, like taint tolerations

### Taint toleration
This only installs on worker nodes. The control-plane and role=storage:NoSchedule
prevent this from running on the control plane and storage nodes respectively.

###  externalTrafficPolicy: Local
This communicates with MetalLB containers running on a control-plane to never
offer that control-plane node as a speaker, because the gateway envoy pod
does not exist on the control-plane, due to control-plane taint.

## Why Envoy?
See `docs/ADR/02-gateway-api.md`

## Important files
k8s/envoy-gateway
- gatewayClass.yaml: Maps envoy controller as the Gateway API impl
- envoy-proxy-cr.yaml: Custom configuration for Envoy-Proxy CR to work with our taints
- helm-values.yaml: Chart values for the pods the chart creates itself - the controller
  Deployment and the certgen pre-install hook Job. These are not the proxy pods, so the
  EnvoyProxy CR above does not cover them; without tolerations here both sit Pending and
  the helm install times out on its pre-install hook.

## Install
This will automatically be run as part of the day 1 Ansible playbook at ansible/playbooks/k8s-init
after the cluster is provisioned and metalLB is installed.

If it fails in the full provisioning, you can rerun this specific installation with:
`ansible-playbook playbooks/k8s-init/main.yml --tags gateway`

## Verify
# If this part runs, you have a new CR you can query, and it should report ACCEPTED: true
kubectl get gatewayclass envoy

# This will show an IP out of our range given to MetalLB
kubectl get gateway -n envoy-gateway-system

# This should show two pods, both status running, and both on worker nodes only
# envoy-envoy-gateway-system-web-gateway-{hash}-{hash} - this is the actual envoy proxy
# envoy-gateway-{hash}-{hash} - this is the controller
kubectl get pods -n envoy-gateway-system -o wide

# Look for Type: LoadBalancer, and an External-IP of the MetalLB pool, and PORT 80
# There will also be a Type: ClusterIP as well without an external IP
kubectl get svc -n envoy-gateway-system

# This one prints out a very long configuration line, but you should see two items at
# the root level, both Kind: service. 1st should have externalTrafficPolicy: local in it's
# spec.
get svc -n envoy-gateway-system -o yaml




## Upgrading

