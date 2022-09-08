output "postgres_endpoint" {
  value = module.superhero-backend-postgres.db_instance_endpoint
}

output "superhero_backend_redis_private_ip" {
  value = module.superhero-backend-redis.private_ip
}

output "graffiti_redis_redis_private_ip" {
  value = module.graffiti-redis.private_ip
}

output "ipfs_private_ip" {
  value = module.ipfs.private_ip
}

output "ipfs_public_ip" {
  value = module.ipfs.public_ip
}

output "superhero_rds_password" {
  value     = local.config.superhero_rds_password
  sensitive = true
}

output "dex_rds_password" {
  value     = local.config.dex_rds_password
  sensitive = true
}

output "testnet_public_ip" {
  value = module.testnet.public_ip
}
