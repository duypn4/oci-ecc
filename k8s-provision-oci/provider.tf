provider "oci" {
    tenancy_ocid = var.tenancy_id
    user_ocid = var.user_id
    private_key_path = var.api_key
    fingerprint = var.api_fingerprint
    region = var.region
}