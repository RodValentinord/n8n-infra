# n8n-infra

Terraform IaC para provisionamento da infraestrutura do n8n self-hosted na **Oracle Cloud (Always Free)**.

---

## Visão Geral

Provisiona 3 VMs ARM Ampere A1 (24 GB RAM total no free tier) com rede, storage e scripts de bootstrap do K3s.

```
┌─────────────────────────────────────────────────────┐
│                  Oracle Cloud (Always Free)          │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐         │
│  │  VM1     │   │  VM2     │   │  VM3     │         │
│  │ K3s      │   │ K3s      │   │ K3s      │         │
│  │ server   │   │ agent-1  │   │ agent-2  │         │
│  │ 1OCPU    │   │ 1.5OCPU  │   │ 1.5OCPU  │         │
│  │ 6GB RAM  │   │ 9GB RAM  │   │ 9GB RAM  │         │
│  └──────────┘   └──────────┘   └──────────┘         │
│         └──────── VCN 10.0.0.0/16 ─────────┘        │
└─────────────────────────────────────────────────────┘
```

## Pré-requisitos

- Terraform >= 1.5
- OCI CLI configurado (`~/.oci/config`) com permissões de manage em VCN e Compute
- Par de chaves SSH gerado localmente
- Quota disponível na sua tenancy OCI (VM.Standard.A1.Flex)

## Quick Start

```bash
# 1. Clone e configure variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edite terraform.tfvars com seus valores reais

# 2. Inicialize
cd terraform
terraform init

# 3. Valide
terraform plan

# 4. Aplique
terraform apply

# 5. Outputs úteis
terraform output server_public_ip
```

## Estrutura do Projeto

```
n8n-infra/
├── terraform/
│   ├── main.tf                  # Provider OCI
│   ├── backend.tf               # State remoto
│   ├── variables.tf             # Inputs
│   ├── outputs.tf               # IPs, IDs
│   ├── network.tf               # VCN, subnets, IGW, security lists
│   ├── compute.tf               # 3 VMs ARM A1
│   ├── storage.tf               # Block volumes (PostgreSQL + Redis)
│   ├── versions.tf              # Required providers
│   └── terraform.tfvars.example # Template de variáveis (sem segredos)
└── scripts/
    ├── k3s-server-init.sh       # Bootstrap K3s server (cloud-init)
    └── k3s-agent-join.sh        # Join agents ao cluster (cloud-init)
```

## Decisões Técnicas

| Decisão | Motivo |
|---|---|
| ARM Ampere A1 | Único shape com 24 GB grátis no OCI Always Free |
| K3s em vez de kubeadm | Footprint menor, ideal para VMs com pouca RAM |
| Traefik desabilitado | Substituído por Nginx Ingress Controller (mais compatível com cert-manager e Cloudflare) |
| Block Volumes externos | PVs separados das VMs para facilitar backup e migração |
| State remoto | Evita conflito em trabalho em equipe e perda de estado local |

## Outputs Esperados

Após `terraform apply`:

| Output | Descrição |
|---|---|
| `server_public_ip` | IP público da VM1 (K3s server) |
| `agent1_public_ip` | IP público da VM2 |
| `agent2_public_ip` | IP público da VM3 |
| `vcn_id` | OCID da VCN criada |
| `public_subnet_id` | OCID da subnet pública |
