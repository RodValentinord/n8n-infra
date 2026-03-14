provider "oci" {
  region = var.region
  # Auth via ~/.oci/config (local) or instance principal (CI).
  # Set TF_VAR_region or export OCI_CLI_REGION to override.
}

# TODO: Extract into child modules (module "network", module "compute") once
#       the flat approach is validated with terraform plan.
