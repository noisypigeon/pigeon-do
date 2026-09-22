resource "cloudflare_dns_record" "mx_primary" {
  zone_id  = local.cloudflare_pigeon_dev_zone_id
  name     = "@"
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  ttl      = 1 # Auto
  comment  = "fastmail primary mx"
}

resource "cloudflare_dns_record" "mx_secondary" {
  zone_id  = local.cloudflare_pigeon_dev_zone_id
  name     = "@"
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 1 # Auto
  comment  = "fastmail secondary mx"
}

resource "cloudflare_dns_record" "dkim_fm1" {
  zone_id = local.cloudflare_pigeon_dev_zone_id
  name    = "fm1._domainkey"
  type    = "CNAME"
  content = "fm1.pigeon.dev.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
  comment = "fastmail primary dkim"
}

resource "cloudflare_dns_record" "dkim_fm2" {
  zone_id = local.cloudflare_pigeon_dev_zone_id
  name    = "fm2._domainkey"
  type    = "CNAME"
  content = "fm2.pigeon.dev.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
  comment = "fastmail secondary dkim"
}

resource "cloudflare_dns_record" "dkim_fm3" {
  zone_id = local.cloudflare_pigeon_dev_zone_id
  name    = "fm3._domainkey"
  type    = "CNAME"
  content = "fm3.pigeon.dev.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
  comment = "fastmail tertiary dkim"
}

resource "cloudflare_dns_record" "spf" {
  zone_id = local.cloudflare_pigeon_dev_zone_id
  name    = "@"
  type    = "TXT"
  content = "\"v=spf1 include:spf.messagingengine.com ?all\""
  ttl     = 1
  comment = "fastmail spf"
}
