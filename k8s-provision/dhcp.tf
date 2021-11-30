resource "oci_core_dhcp_options" "dhcp-options"{
    compartment_id = var.sandbox_id
    vcn_id = module.vcn.vcn_id
    options {
        type = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
    }
    display_name = "k8s-dhcp-options"
}