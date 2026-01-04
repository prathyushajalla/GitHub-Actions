module "plink" {
  source = "../../Modules/Private-Link-App/"

  env      = var.env
  location = var.location
}