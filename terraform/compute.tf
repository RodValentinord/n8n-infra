# Dynamically fetch the latest Oracle Linux 8 ARM image for the region.
data "oci_core_images" "ol8_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.vm_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# VM1 — K3s Server (1 OCPU / 6 GB)
# Less resources than workers because the control plane is lightweight;
# the bulk of CPU/RAM goes to the agents that run actual workloads.
resource "oci_core_instance" "k3s_server" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project}-server"
  shape               = var.vm_shape
  freeform_tags       = local.freeform_tags

  shape_config {
    ocpus         = var.server_ocpus
    memory_in_gbs = var.server_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/../scripts/cloud-init.sh"))
  }
}

# VM2 — K3s Agent 1 (1.5 OCPU / 9 GB)
resource "oci_core_instance" "k3s_agent1" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project}-agent1"
  shape               = var.vm_shape
  freeform_tags       = local.freeform_tags

  shape_config {
    ocpus         = var.agent_ocpus
    memory_in_gbs = var.agent_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/../scripts/cloud-init.sh"))
  }
}

# VM3 — K3s Agent 2 (2 OCPU / 9 GB)
# Gets 2 OCPUs to use all 4 free OCPUs: server(1) + agent1(1) + agent2(2) = 4
resource "oci_core_instance" "k3s_agent2" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project}-agent2"
  shape               = var.vm_shape
  freeform_tags       = local.freeform_tags

  shape_config {
    ocpus         = var.agent2_ocpus
    memory_in_gbs = var.agent_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/../scripts/cloud-init.sh"))
  }
}
