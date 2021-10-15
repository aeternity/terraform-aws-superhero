output "postgres_endpoint" {
  value = module.superhero-backend-postgres.db_instance_endpoint
}

output "redis_private_ip" {
  value = module.superhero-backend-redis.private_ip
}
