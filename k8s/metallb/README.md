# MetalLB
External load balancer to get a public IP address for the k8s cluster. On-prem k8s has no way to setup a
unique IP address for the entire cluster. MetalLB sets up an external IP as a load balancer

## Why MetalLB?
See `docs/ADR/01-load-balancer.md` for why MetalLB

## Important files
k8s/metallb
- values.yaml - Values overrides for the metalLB chart, needed to overcome our worker/storage node taints
- pool-chart - custom chart to manage metalLB's pool of IP addresses to use
  - Chart.yaml - what it says on the tin
  - values.yaml - overrides for chart, empty definition of addressPoolCIDR so helm will complain if the user forgets to set it
  - templates - metalLB expects users to setup custom resource definitions (CRD) for IP pools and ARP configuration
    - ip-address-pool.yaml - pipes .env variable for a resource pool CR
    - l2-advertisement.yaml - CR for configuration for ARP advertisement CR

## Install
This will automatically be run as part of the day 1 Ansible playbook at ansible/playbooks/k8s-init
directly after provisioning the cluster, from the toolbox container. 

The equivalent commands, for reference/troubleshooting by hand from the toolbox
(`start-toolbox`):

```bash
# helm repo add <REPO_ALIAS> <URL>
helm repo add metallb https://metallb.github.io/metallb --force-update
helm repo update

# Reminder: helm install <APP_ALIAS> <REPO_ALIAS>/<CHART_NAME>
helm upgrade --install metallb metallb/metallb \
  --version "$METALLB_CHART_VERSION" \
  --namespace metallb-system \
  --create-namespace \
  -f k8s/metallb/values.yaml

# IPAddressPool/L2Advertisement live in their own tiny local chart (k8s/metallb/pool-chart)
# instead of a kubectl-applied manifest, so the pool address comes in through Helm's own
# Go templating (--set) rather than a separate substitution tool.
helm upgrade --install metallb-pool k8s/metallb/pool-chart \
  --namespace metallb-system \
  --set addressPoolCIDR="$METALLB_ADDRESS_POOL_CIDR"
```

## Verify
```bash
kubectl get pods -n metallb-system -o wide   # speaker should be Running on all 3 nodes
kubectl get ipaddresspool,l2advertisement -n metallb-system # metalLB registers these as custom kube resources
```

A `Service` of `type: LoadBalancer` should then get an `EXTERNAL-IP` from
`METALLB_ADDRESS_POOL_CIDR` (set in `toolbox/.env`).

## Updating IP addresses
- Update `METALLB_ADDRESS_POOL_CIDR` changes in `toolbox/.env`
- `ansible-playbook playbooks/k8s-init/main.yml --tags metallb`

## Upgrading
- `metallb/metallb`: 
  - Update `METALLB_CHART_VERSION` in `toolbox/.env`
  - re-run `ansible-playbook playbooks/k8s-init/main.yml --tags metallb` 
  - verify `k8s/metallb/values.yaml` still applies cleanly against the new chart's `values.schema.json`

