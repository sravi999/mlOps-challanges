data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "workbench1" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "workbench1"
  }

}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "rds-cluster-pg"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "max_connections"
    value = var.db_parameter_group_max_connections
  }

}

resource "aws_rds_cluster_instance" "this" {
  count              = 2
  identifier         = "aurora-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.r4.large"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = var.cluster_identifier_name
  engine                          = var.rds_engine
  engine_version                  = var.rds_engine_version
  availability_zones              = var.rds_availability_zones
  database_name                   = var.rds_managed_db_name
  master_username                 = var.rds_managed_db_master_name
  master_password                 = var.rds_db_instance_password
  backup_retention_period         = var.rds_backup_retention_period
  preferred_backup_window         = "07:00-09:00"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  skip_final_snapshot             = true

}


resource "aws_iam_group" "iam_group" {
  name = var.iam_group_name
}

resource "aws_iam_user" "iam_users" {
  count = length(var.iam_users)
  name  = var.iam_users[count.index]
}

resource "aws_iam_group_membership" "iam_group_membership" {
  name  = "tf-users-group"
  group = aws_iam_group.iam_group.name
  users = aws_iam_user.iam_users[*].name
}

# resource "aws_s3_bucket_acl" "example" {

#   bucket = aws_s3_bucket.public_bucket.id
#   acl    = "public-read"
# }

resource "aws_s3_bucket" "public_bucket" {
  bucket = "tf-ravi-ml-public-bucket"
  # acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.public_bucket.arn}/*",
      },
    ],
  })
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "tf-ravi-ml-private-bucket"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.private_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowExternalAccount",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::385880150447:root"
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.private_bucket.arn}/*"
      }
    ],
  })
}