module "vcn" {
    source  = "oracle-terraform-modules/vcn/oci"
    version = "2.0.0"
    
    compartment_id = var.sandbox_id
    region = var.region
    vcn_name = "k8s"
    vcn_dns_label = "k8s"

    internet_gateway_enabled = true
    service_gateway_enabled = true
    vcn_cidr = "10.0.0.0/16"
}