data "aws_secretsmanager_secret_version" "db-creds" {
  secret_id = "db-creds"
}

resource "aws_db_instance" "jmiro-db" {
  allocated_storage    = 100
  engine               = "postgres"
  engine_version       = "12.4"
  identifier           = "jmiro-db"
  instance_class       = "db.m5.large"
  username             = jsondecode(data.aws_secretsmanager_secret_version.db-creds.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.db-creds.secret_string)["password"]
  vpc_security_group_ids = [aws_security_group.rds_jmiro.id]
  final_snapshot_identifier = "jmiro-db-backp"
  skip_final_snapshot = true
}