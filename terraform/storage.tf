# Block volumes are created but NOT attached to instances.
# Attachment will happen later via K3s PersistentVolumeClaims.

resource "oci_core_volume" "postgres" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  display_name        = "${var.project}-vol-postgres"
  size_in_gbs         = 50
  freeform_tags       = local.freeform_tags
}

resource "oci_core_volume" "redis" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  display_name        = "${var.project}-vol-redis"
  size_in_gbs         = 50
  freeform_tags       = local.freeform_tags
}
