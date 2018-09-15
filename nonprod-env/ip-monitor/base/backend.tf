terraform {
  backend "local" {
    path = "../../../../tfstate/nonprod-env/ip-monitor/base/tfstate.tfstate"
  }
}