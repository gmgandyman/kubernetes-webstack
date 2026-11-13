# Global stuff

variable "scripts_root" {
    type    = string
    default = "packer/scripts"
}

variable "output_root" {
    type    = string
    default = "packer/output"
}

variable "public_key_path" {
    type    = string
    default = env("DEPLOY_PUBLIC_KEY_PATH")
}

variable "deploy_private_key_path" {
    type    = string
    default = env("DEPLOY_PRIVATE_KEY_PATH")
}

variable "kubernetes_version" {
    type    = string
    default = env("KUBERNETES_VERSION")
}

# Full x.y.z - these are upstream release tags, not apt versions (see
# packer/ansible/roles/setup-linux-for-k8s/tasks/setup-containerd.yml)
variable "containerd_version" {
    type    = string
    default = env("CONTAINERD_VERSION")
}

variable "runc_version" {
    type    = string
    default = env("RUNC_VERSION")
}

variable "cni_plugins_version" {
    type    = string
    default = env("CNI_PLUGINS_VERSION")
}
