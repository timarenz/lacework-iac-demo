provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias      = "plain_text_static_credentials"
  region     = var.aws_region
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

resource "random_id" "id" {
  byte_length = 3
}

data "http" "current_ip" {
  url = "https://api4.my-ip.io/ip.json"
}

module "environment" {
  source           = "timarenz/environment/aws"
  environment_name = var.environment_name
  owner_name       = var.owner_name
  nat_gateway      = false
}

