terraform {
  backend "local" {
    path = "../../../../tfstate/vpc-example/n/terraformstate.tfstate"
  }
}