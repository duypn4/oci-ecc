resource "oci_core_subnet" "public-subnet" {
    compartment_id = var.sandbox_id
    vcn_id = module.vcn.vcn_id
    cidr_block = "10.0.1.0/24"
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    route_table_id = module.vcn.ig_route_id
    security_list_ids = [oci_core_security_list.public-security-list.id]
    display_name = "k8s-public-subnet"
}