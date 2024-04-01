resource "digitalocean_container_registry" "container" {
  name                   = "weerwijzer-container"
  subscription_tier_slug = "starter"
  region = var.region
}