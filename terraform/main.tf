locals {
  freeform_tags = {
    project    = "n8n-selfhosted"
    managed_by = "terraform"
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
  # Auth: reads ~/.oci/config locally.
  # In CI, leave config absent and export OCI_TENANCY_OCID, OCI_USER_OCID,
  # OCI_FINGERPRINT, OCI_PRIVATE_KEY, OCI_REGION — the provider picks them up
  # automatically as environment variables.
}

# Lookup the first AD in the region — São Paulo has a single AD.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  ad = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
