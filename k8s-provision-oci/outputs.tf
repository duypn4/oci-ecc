output "all-availability-domains-in-tenancy" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

output "all-ubuntu-images-in-compartment" {
  value = data.oci_core_images.ubuntu.images
}

output "vcn_id" {
  value = module.vcn.vcn_id
}

output "public_route_table_id" {
  value = module.vcn.ig_route_id
}

output "public_security_list_id" {
  value = oci_core_security_list.public-security-list.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public-subnet.id
}

output "dhcp-options-id" {
  value = oci_core_dhcp_options.dhcp-options.id
}