resource "oci_containerengine_cluster" "oke-cluster" {
    compartment_id = "${var.sandbox_id}"
    kubernetes_version = "v1.17.9"
    name = "coded_computing"
    vcn_id = "${module.vcn.vcn_id}"
    options {
        add_ons{
            is_kubernetes_dashboard_enabled = false
            is_tiller_enabled = false
        }
        kubernetes_network_config {
            pods_cidr = "10.244.0.0/16"
            services_cidr = "10.96.0.0/16"
        }
        service_lb_subnet_ids = ["${oci_core_subnet.public-subnet.id}"]
    }  
}