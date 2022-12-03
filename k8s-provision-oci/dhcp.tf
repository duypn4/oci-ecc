resource "oci_core_dhcp_options" "dhcp-options"{
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = module.vcn.vcn_id
    options {
        type = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
    }
    display_name = "k8s-dhcp-options"
}