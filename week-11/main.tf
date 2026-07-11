resource "openstack_compute_instance_v2" "tf-vm-1" {
  name      = "tf-vm-1"
  image_name = "cirros-0.6.3-x86_64-disk"
  flavor_name = "m1.small"

  network {
    name = "week11-net"
  }
}

resource "openstack_compute_instance_v2" "tf-vm-2" {
  name      = "tf-vm-2"
  image_name = "cirros-0.6.3-x86_64-disk"
  flavor_name = "m1.small"

  network {
    name = "week11-net"
  }
}

resource "aws_s3_bucket" "multicloud" {
  bucket = "intern-multicloud-demo-renzkirby"
}
