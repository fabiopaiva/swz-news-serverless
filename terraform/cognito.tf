resource "aws_cognito_user_pool" "swz_auth_pool" {
  name = format("swz-auth-cognito-%s", local.environment)

  tags = local.tags
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = format("swz-auth-identity-pool-%s", local.environment)
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = format("swz_auth_identity_pool_%s", local.environment)
    provider_name           = aws_cognito_user_pool.swz_auth_pool.endpoint
    server_side_token_check = false
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_domain" "swz_auth_pool_domain" {
  domain          = format("auth.%s", var.domain_name)
  user_pool_id    = aws_cognito_user_pool.swz_auth_pool.id
  certificate_arn = aws_acm_certificate.cloudfront_cert.arn
}

resource "aws_cognito_resource_server" "swz_news_auth_pool_resource_server" {
  identifier = "news"
  name       = "news"
  user_pool_id = aws_cognito_user_pool.swz_auth_pool.id

    scope {
      scope_name        = "write"
      scope_description = "Allow to add news"
    }

}

resource "aws_cognito_user_pool_client" "swz_auth_pool_client" {
  name = format("swz-news-client-%s", local.environment)

  user_pool_id                         = aws_cognito_user_pool.swz_auth_pool.id
  generate_secret                      = true
  refresh_token_validity               = 7
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["news/write"]
  depends_on = [aws_cognito_resource_server.swz_news_auth_pool_resource_server]
}

// Exposing these values is not ideal in a production environment
output "swz_news_client_authentication" {
  value = {
    endpoint      = aws_cognito_user_pool.swz_auth_pool.endpoint
    client_id     = aws_cognito_user_pool_client.swz_auth_pool_client.id
    client_secret = aws_cognito_user_pool_client.swz_auth_pool_client.client_secret
  }
}
output "token_url" {
  value = format("curl -X POST https://%s/oauth2/token -H 'content-type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&scope=%s' -H 'Authorization: Basic %s'",
  aws_cognito_user_pool_domain.swz_auth_pool_domain.domain,
  "news%2Fwrite",
  base64encode(format("%s:%s", aws_cognito_user_pool_client.swz_auth_pool_client.id, aws_cognito_user_pool_client.swz_auth_pool_client.client_secret))
  )
}
