#Estable donde se almacenara nuestro backend
terraform {
  backend "local" {
    path = "terraformAWS.tfstate"
  }
}