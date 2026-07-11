provider "openstack" {
  auth_url            = "http://10.1.0.4/identity/v3"
  user_name           = "admin"
  password            = "admin123"
  tenant_name         = "admin"
  user_domain_name    = "Default"
  project_domain_name = "Default"
  region              = "RegionOne"
}

provider "aws" {
  region = "ap-southeast-2"
}
