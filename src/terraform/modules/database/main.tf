# Phase 2 — Research test database (RDS).
# Ref: 02-Cloud-Infrastructure.md "Test database (RDS)" line item and
# 04-Security-Policy.md "Data Classification" — this instance is for
# synthetic/throwaway lab data only (e.g. seeding from app/web's Faker
# records), never real personal data. Encrypted at rest, private-subnet
# only, no public access, master credential managed by RDS in Secrets
# Manager (never stored in Terraform state or passed as a variable).

resource "aws_kms_key" "rds" {
  description             = "${var.name} RDS encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db-subnets" })
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Research test database: Postgres from workload SG only, no public access"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "Postgres from research workloads"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-db-sg" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-labdb"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  db_name  = var.database_name
  username = var.master_username
  # RDS creates and rotates the master password itself, stored in Secrets
  # Manager — Terraform never sees or stores the plaintext value.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_days

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  auto_minor_version_upgrade = true

  tags = merge(var.tags, { Name = "${var.name}-labdb", DataClassification = "synthetic-only" })
}
