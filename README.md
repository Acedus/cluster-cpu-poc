# cluster-cpu-poc

Public POC for extracting a sorted list of hosts and their CPU models based on Kubevirt's node-labeller labels in order to determine optimal default cluster CPU.

The selection is quantitative and is done according to `host-model-required-features.node.kubevirt.io` node labels as migration logic relies on them for scheduling the migration Pod (the main usecase of this feature).

Qualitative analysis extends beyond the current capabilities of Kubevirt as the virt-handler's node labeling logic infers the available node features from libvirt (`virsh domcapabilities`) which currently doesn't provide CPU model metadata.

# Notes

* Requires `kubectl` and `jq`.
