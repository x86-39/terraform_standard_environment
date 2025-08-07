data "cloudflare_zones" "other_zones" {
  for_each = {
    for site in var.dns_records : site.name => site
    if site.domain != null && site.domain != ""
  }
  name = each.value.domain
}

data "cloudflare_zones" "default_zone" {
  count = var.cloudflare_default_domain != "" ? 1 : 0
  name = var.cloudflare_default_domain
}

resource "cloudflare_dns_record" "sites" {
  for_each = {
    for site in var.dns_records : site.name => site
  }
  zone_id         = coalesce(each.value.domain_id, try(data.cloudflare_zones.other_zones[each.key].result[0].id, ""), try(data.cloudflare_zones.default_zone[0].result[0].id, ""), var.cloudflare_default_domain_id)
  name            = each.value.name
  content         = each.value.value
  type            = coalesce(each.value.type, var.cloudflare_default_type)
  ttl             = coalesce(each.value.ttl, var.cloudflare_default_ttl) # Cloudflare provider uses seconds
  proxied         = coalesce(each.value.proxied, var.cloudflare_default_proxied)
}
