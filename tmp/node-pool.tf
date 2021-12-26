resource "oci_containerengine_node_pool" "oke-node-pool" {
    # Required
    cluster_id = "${oci_containerengine_cluster.oke-cluster.id}"
    compartment_id = "${var.sandbox_id}"
    kubernetes_version = "${var.k8s_version}"
    name = "coded_computing_pool"
    node_config_details {
        placement_configs {
            availability_domain = "${data.oci_identity_availability_domains.ads.availability_domains[0].name}"
            subnet_id = "${oci_core_subnet.public-subnet.id}"
        }
        size = 3
    }
    node_shape = "<node-shape>" 
    node_source_details {
         image_id = "<image-ocid>"
         source_type = "image"
    }
    initial_node_labels {
        key = "name"
        value = ""
    }
}