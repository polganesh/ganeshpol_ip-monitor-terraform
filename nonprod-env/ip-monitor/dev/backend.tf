terraform {
  backend "local" {
    path = "../../../../tfstate/nonprod-env/ip-monitor/dev/tfs.tfstate"
  }
}