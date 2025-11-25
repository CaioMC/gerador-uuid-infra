# -----------------------------------------------------------------------------------
# 1. ECR Repository
# -----------------------------------------------------------------------------------
resource "aws_ecr_repository" "gerador_uuid_core" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}