# Block Volume — PostgreSQL persistent data
resource "oci_core_volume" "postgres" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${var.project}-vol-postgres"
  size_in_gbs         = 50
  # TODO: Attach a backup policy (OCI Backup Policy OCID)
}

resource "oci_core_volume_attachment" "postgres" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.k3s_agent1.id
  volume_id       = oci_core_volume.postgres.id
  display_name    = "${var.project}-attach-postgres"
}

# Block Volume — Redis persistent data
resource "oci_core_volume" "redis" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${var.project}-vol-redis"
  size_in_gbs         = 20
}

resource "oci_core_volume_attachment" "redis" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.k3s_agent2.id
  volume_id       = oci_core_volume.redis.id
  display_name    = "${var.project}-attach-redis"
}
