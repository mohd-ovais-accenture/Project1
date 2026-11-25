# Project 1: Deploy a Linux EC2 Web Server using Terraform

Provisions a VPC, public subnet, internet gateway, route table, HTTP security group (port 80 only), and an Ubuntu EC2 instance running Nginx via `user_data`.

## Files
- `main.tf` — Terraform AWS infrastructure configuration
- `userdata.sh` — Startup script that installs Nginx and serves a sample webpage
- `.gitignore` — Excludes Terraform state and cache files

## Usage
```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply

## Output
public_ip = "18.209.34.229"
webpage_url = "http://18.209.34.229"
