resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${var.project}-vcn"
  dns_label      = "n8nvcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-sl-public"

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    tcp_options { min = 80; max = 80 }
  }
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    tcp_options { min = 443; max = 443 }
  }
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    tcp_options { min = 22; max = 22 }
  }
  # K3s API server — restricted to VCN internal
  ingress_security_rules {
    protocol  = "6"
    source    = "10.0.0.0/16"
    tcp_options { min = 6443; max = 6443 }
  }
  # K3s Flannel VXLAN — intra-cluster
  ingress_security_rules {
    protocol  = "17" # UDP
    source    = "10.0.0.0/16"
    udp_options { min = 8472; max = 8472 }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "${var.project}-subnet-public"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "${var.project}-subnet-private"
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
  # TODO: Add NAT Gateway + private route table for egress
}
