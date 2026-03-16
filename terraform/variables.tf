variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment where all resources will be created"
  type        = string
}

variable "region" {
  description = "OCI region identifier (e.g. sa-saopaulo-1)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content injected into VMs (e.g. contents of ~/.ssh/id_rsa.pub)"
  type        = string
  sensitive   = true
}

variable "vm_shape" {
  description = "Compute shape for all VMs (ARM AmpereOne A2)"
  type        = string
  default     = "VM.Standard.A2.Flex"
}

variable "server_ocpus" {
  description = "OCPUs for K3s server — 1 OCPU leaves more compute for the workers"
  type        = number
  default     = 1
}

variable "server_memory_gb" {
  description = "Memory (GB) for K3s server — control plane needs less than workers"
  type        = number
  default     = 6
}

variable "agent_ocpus" {
  description = "OCPUs per K3s agent — must be integer; 1+1+2=4 uses the full free tier (server=1, agent1=1, agent2=2)"
  type        = number
  default     = 1
}

variable "agent2_ocpus" {
  description = "OCPUs for K3s agent-2 — set to 2 to use all 4 free OCPUs (server=1 + agent1=1 + agent2=2)"
  type        = number
  default     = 2
}

variable "agent_memory_gb" {
  description = "Memory (GB) per K3s agent — workers run n8n, Postgres, Redis workloads"
  type        = number
  default     = 9
}

variable "project" {
  description = "Short name used as resource-name prefix"
  type        = string
  default     = "n8n"
}
