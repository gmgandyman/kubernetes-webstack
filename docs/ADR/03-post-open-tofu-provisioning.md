# Post-open tofu provisioning
Terraform/open tofu hits a wall when it comes to provisioning all the k8s configuration after
the VMs come online. Something has to manage:
1. Checking which nodes have been joined
2. Generating a join token on the control plane
3. Passing the token it to unjoined nodes so they can join the cluster
4. Pulling down the control-plane's kube.conf file for kubectl commands
5. Configuring the external load balancer
6. Configuring the gateway API

And all of this happens in the Linux OS, which is not open tofu's domain

## Options
1. Bash scripts run from cloud-init
2. Ansible
3. Argo
4. Flux

## Decision
Ansible

## Why
It's the lightest weight solution that supports something like easy integration with Linux, kubectl, helm, etc. in
an idempotent fashion. This means as new nodes come up, the playbooks can safely be run again, and even specifically
targeting certain tasks or VMs.

However, once this moves into more automated territory, instead of just turning up a simple 3-5 node cluster, everything
after the initial kubernetes initialization needs to move into Flux.

## Why not X
### Bash scripts
No idempotence, no logging, brittle, difficult for most people to read and understand, difficult to recover from if
something stops midway through

### Argo
This is more of a central control center with a visual UI, not what I'm looking for with IaC

### Flux
The honest answer is this is the real IaC solution, especially at scale. However, given all that's being 
figured out and turned up (metalLB, envoy, python web apps, postgres, redis), this is too heavy of a lift at
this time. But 60-80% of what is in Ansible needs to move into Flux at some point.