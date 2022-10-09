data "oci_identity_availability_domains" "ads" {
    compartment_id = var.tenancy_id
}

data "oci_core_images" "ubuntu" {
    compartment_id = oci_identity_compartment.compartment.id
    operating_system = var.os_name
    operating_system_version = var.os_version
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}