variable "cf_origin_domain_name" {
  type        = string
  description = "The domain name of the origin that the CloudFront distribution will use."
}

variable "cf_aliases" {
  type        = list(string)
  description = "The list of CNAME aliases to associate with the CloudFront distribution."
}

variable "cf_comment" {
  type        = string
  description = "An optional comment to describe the CloudFront distribution."
}

variable "cf_price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "The price class for the CloudFront distribution. Possible values: PriceClass_100, PriceClass_200, PriceClass_All."
}

variable "cf_enabled" {
  type        = bool
  default     = true
  description = "Whether the CloudFront distribution is enabled."
}

variable "cf_default_root_object" {
  type        = string
  default     = "index.html"
  description = "The default root object for the CloudFront distribution."
}

variable "lb_arn" {
  type        = string
  description = "The ARN of the AWS Load Balancer to use as the origin for the CloudFront distribution."
}

variable "lb_port" {
  type        = string
  default     = "80"
  description = "The port on which the AWS Load Balancer is listening."
}

variable "lb_protocol" {
  type        = string
  default     = "http"
  description = "The protocol that the AWS Load Balancer is using. Possible values: http, https."
}

variable "viewer_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate to use for HTTPS encryption"
}
