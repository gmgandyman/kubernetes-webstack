# Load Balancer
The cluster needs a static IP address in order to route packets to the service. There is nothing provided
out of the box on a k8s cluster for this.

## Note
I know nearly nothing here, so this document is likely working off of bad assumptions and hard lessons I have
not yet learned.

## Options
1. MetalLB
2. KubeVIP
3. Cilium

## Choice
MetalLB

## Why
Because it's the lightest implementation for an "external" load balancer for the application layer, which is all I'm
looking for at this point.

## Why not X
### KubeVIP
This provides much more functionality, including control plane HA, which I don't need yet

### Cilium
It would require replacing the Flannel CNI, and I'm not interested in that lift at this point