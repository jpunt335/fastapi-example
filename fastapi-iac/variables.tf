variable "do_token" {
  type = string
  default = "dop_v1_54768fea7051d1b3bcaa29e659330cf6a44eedc269130bc4057b45d218dcec85"
}

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


variable domain_name {
  description = "Top level domains to create records and pods for"
  type    = list(string)
  default = ["weerwijzer-belastingdienst.online"]
}

variable digitalocean_token {
  description = "The API token from your Digital Ocean control panel"
  type = string
  default        = "dop_v1_91eaaf0a682f447686523f5ee41cb888f56dae864bdc7e0a2433420f232cb418"
}


variable letsencrypt_email {
  type = string
  default = "justin.punt@novi-education.nl"
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