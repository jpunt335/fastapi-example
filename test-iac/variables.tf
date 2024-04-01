variable "do_token" {}

variable "region"{
    type = string
    default = "ams3"
}

variable "cluster_name"{
    type = string
    default = "k8s-cluster"
}
variable "k8s_version"{
    type = string
    default = "1.29.1-do.0"
}
variable "node_size"{
    type = string
    default = "s-2vcpu-2gb"
}
variable "node_count"{
    type = number
    default = 3
}
variable "nginx_svc_name"{
    type = string
    default = "nginx-ingress-ingress-nginx-controller"
}

variable "domain_name"{
    type = string
    default = "weerwijzer-belastingdienst.online"
}
variable digitalocean_token {
  description = "The API token from your Digital Ocean control panel"
  type        = string
}


variable letsencrypt_email {
  type = string
}

variable min_nodes {
  description = "The minimum number of nodes in the default pool"
  type        = number
  default     = 1
}

variable max_nodes {
  description = "The maximum number of nodes in the default pool"
  type        = number
  default     = 3
}

variable default_node_size {
  description = "The default digital ocean node slug for each node in the default pool"
  type        = string
  default     = "s-1vcpu-2gb"
}

