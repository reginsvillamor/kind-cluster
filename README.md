## To create local dev `Kind` cluster

#### Prerequisites
- Installed `terraform`


#### To create `Kind` cluster via terraform
- Run `terraform init`
  ```
  ~/Workspace/hashicorp/kind-iac $ terraform init
  ```
- Run `terraform plan`
  ```
  ~/Workspace/hashicorp/kind-iac $ terraform plan
  ```
- Run `terraform apply`.
  ```
  ~/Workspace/hashicorp/kind-iac $ terraform apply

  Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

  Outputs:

  kubernetes_endpoint = "https://127.0.0.1:60396"
  kubernetes_service_host = "10.96.0.1"  
  ```  