#Estable donde se almacenara nuestro backend
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "demosmayraespinoza"

    workspaces {
      name = "AWS-TERRAFORM"
    }
  }
}
