locals {
  # TODO: Replace with the latest Ubuntu 22.04 ARM image OCID for your region.
  # Look up: oci compute image list --compartment-id <compartment> \
  #           --operating-system "Canonical Ubuntu" --shape VM.Standard.A1.Flex
  ubuntu_arm_image_ocid = "TODO: replace-with-regional-arm-image-ocid"
}

# VM1 — K3s Server (1 OCPU / 6 GB)
resource "oci_core_instance" "k3s_server" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.project}-server"
  shape               = var.vm_shape

  shape_config {
    ocpus         = var.server_ocpus
    memory_in_gbs = var.server_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_arm_image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = filebase64("${path.module}/../scripts/k3s-server-init.sh")
  }
}

# VM2 — K3s Agent 1 (1.5 OCPU / 9 GB)
resource "oci_core_instance" "k3s_agent1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.project}-agent1"
  shape               = var.vm_shape

  shape_config {
    ocpus         = var.agent_ocpus
    memory_in_gbs = var.agent_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_arm_image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # TODO: Pass K3S_TOKEN and server IP via OCI Secrets or SSM Parameter Store
    user_data = filebase64("${path.module}/../scripts/k3s-agent-join.sh")
  }
}

# VM3 — K3s Agent 2 (1.5 OCPU / 9 GB)
resource "oci_core_instance" "k3s_agent2" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.project}-agent2"
  shape               = var.vm_shape

  shape_config {
    ocpus         = var.agent_ocpus
    memory_in_gbs = var.agent_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_arm_image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = filebase64("${path.module}/../scripts/k3s-agent-join.sh")
  }
}
