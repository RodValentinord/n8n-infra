variable "region" {
  description = "OCI region identifier (e.g. sa-saopaulo-1)"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the target compartment"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain name (e.g. Xxxx:SA-SAOPAULO-1-AD-1)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key injected into VMs via cloud-init"
  type        = string
  sensitive   = true
}

variable "vm_shape" {
  description = "Compute shape for all VMs (ARM Ampere A1)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "server_ocpus" {
  type    = number
  default = 1
}

variable "server_memory_gb" {
  type    = number
  default = 6
}

variable "agent_ocpus" {
  type    = number
  default = 1
}

variable "agent_memory_gb" {
  type    = number
  default = 9
}

variable "project" {
  description = "Short name used as resource prefix"
  type        = string
  default     = "n8n"
}
