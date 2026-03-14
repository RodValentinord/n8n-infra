output "server_public_ip" {
  description = "Public IP of K3s server VM"
  value       = oci_core_instance.k3s_server.public_ip
}

output "agent1_public_ip" {
  description = "Public IP of K3s agent-1 VM"
  value       = oci_core_instance.k3s_agent1.public_ip
}

output "agent2_public_ip" {
  description = "Public IP of K3s agent-2 VM"
  value       = oci_core_instance.k3s_agent2.public_ip
}

output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}
