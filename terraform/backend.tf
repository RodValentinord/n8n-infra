# TODO: Configure remote backend.
# Option A — OCI Object Storage (free):
# terraform {
#   backend "s3" {
#     bucket                      = "tfstate-bucket"
#     key                         = "n8n-infra/terraform.tfstate"
#     region                      = "sa-saopaulo-1"
#     endpoint                    = "https://<namespace>.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     force_path_style            = true
#   }
# }
#
# Option B — Terraform Cloud (free tier):
# terraform {
#   cloud {
#     organization = "your-org"
#     workspaces { name = "n8n-infra" }
#   }
# }
