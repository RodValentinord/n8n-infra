terraform {
  backend "s3" {
    bucket   = "n8n-tfstate"
    key      = "terraform.tfstate"
    region   = "sa-saopaulo-1"
    endpoint = "https://grvkelfysqpa.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    profile  = "oci-n8n"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
