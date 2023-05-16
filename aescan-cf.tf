module "aescan_cdn" {
  count = local.only_in_production
  source = "terraform-aws-modules/cloudfront/aws"
  aliases = ["${local.config.cdn_aliases}"] #aescan.prd.aepps.com 

  comment             = "Aescan CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true

  create_origin_access_identity = false
  origin = {
    aescan = {
      domain_name = local.config.cdn_domain_name #"prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
      origin_id = local.config.cdn_origin_id #"prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = local.config.cdn_target_origin_id #"prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values = false
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = false
    cache_policy_id = "471206cb-8312-4b46-b64a-2255875a0d07" # will be implemented here in tf
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # will be implemented here in tf
    viewer_protocol_policy   = "redirect-to-https"
  }

  viewer_certificate = {
    acm_certificate_arn = local.config.cdn_acm_certificate_arn #"arn:aws:acm:us-east-1:106102538874:certificate/3d041f97-8742-4cea-b58b-91e41fd23177"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
