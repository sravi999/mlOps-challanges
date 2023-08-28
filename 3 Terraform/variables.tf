variable "aws_region" {
  default     = "ap-south-1"
  type        = string
  description = "Specify the aws region to create the resources"
}

variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "EC2 Instance type"
}

variable "rds_db_instance_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "iam_users" {
  default     = ["vera", "chuck", "dave"]
  type        = list(any)
  description = "list of IAM Users names"
}


variable "db_parameter_group_max_connections" {
  default     = 16000
  type        = number
  description = "max number of simultaneous connections"
}

variable "cluster_identifier_name" {
  type        = string
  default     = "rds-aurora-cluster"
  description = "Name of the rds cluster"
}

variable "rds_engine" {
  type        = string
  default     = "aurora-mysql"
  description = "RDS cluster engine"
}

variable "rds_engine_version" {
  type        = string
  default     = "5.7.mysql_aurora.2.11.2"
  description = "RDS enginer version"
}

variable "rds_availability_zones" {
  type        = list(any)
  default     = ["ap-south-1a", "ap-south-1b"]
  description = "RDS Cluster nodes in different availability zone"

}

variable "rds_managed_db_name" {
  type        = string
  default     = "rdsmanageddatabase"
  description = "RDS cluster managed database name"
}

variable "rds_managed_db_master_name" {
  type        = string
  default     = "root"
  description = "RDS cluster managed database master user name"
}

variable "rds_backup_retention_period" {
  type        = number
  default     = 1
  description = "retention period"
}

variable "iam_group_name" {
  type        = string
  default     = "developer"
  description = "Name of the IAM group"
}