# basic-networking-submission

**Proyek Membangun Web Server (Apache2, Nginx & Node.js)** adalah submission akhir untuk kelas [Belajar Jaringan Komputer untuk Pemula - Dicoding](https://www.dicoding.com/academies/387).

Otomatisasi deployment dan konfigurasi menggunakan tools IaC (Infrastucture as Code):

- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)

## Requirements

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform v1.2.6+](https://www.terraform.io/downloads)
- [Ansible v2.12.5+](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Installasi

1. Clone repository

   ```sh
   git clone https://github.com/andrijunaedi/basic-networking-submission.git
   cd basic-networking-submission
   ```

2. Copy `terraform.trfvars-example` ke `terraform.tfvars` dan sesuaikan valuenya.

   ```sh
   cp terraform.trfvars-example terraform.tfvars
   nano terraform.tfvars
   ```

   Note:

   - `profile`: profile AWS Credentials
   - `public_key`: path public key SSH
   - `private_key`: path private key SSH

3. Init Terraform

   ```sh
   terraform init
   ```

4. Terraform plan

   ```sh
   terraform plan
   ```

5. Apply terraform

   ```sh
   terraform apply

   # Terraform apply auto approve
   terraform apply -auto-approve
   ```

## Destroy semua infrastructure

```sh
terraform destroy

# Terraform destroy auto approve
terraform destroy -auto-approve
```

## Modules

- [Terraform - AWS VPC](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Terraform - AWS EC2 Instance](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)

## Troubleshoot

### Re-run ansible playbook secara manual

`ansible_command` berikut ada pada outputs terraform:

```sh
 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '$PUBLIC_IP,' --private-key $PRIVATE_KEY -e 'pub_key=$PUBLIC_KEY' playbooks/setup-webserver.yml
```
