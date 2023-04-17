resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.cf_origin_domain_name
    custom_origin_config {
      http_port              = var.lb_port
      https_port             = var.lb_port
      origin_protocol_policy = var.lb_protocol
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = var.cf_enabled
  comment             = var.cf_comment
  price_class         = var.cf_price_class
  aliases             = var.cf_aliases
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "1"
    forwarded_values {
      query_string = false
      headers      = ["Host"]
      cookies {
        forward = var.cookies_forward
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
  restrictions {
    geo_restriction {
      restriction_type = var.restrictions_geo_restriction_type
    }
  }
  viewer_certificate {
    acm_certificate_arn = var.viewer_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
