resource "oci_core_security_list" "public-security-list" {
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = module.vcn.vcn_id
    display_name = "k8s-public-sl"

    egress_security_rules {
        stateless = false
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
    }
    
    ingress_security_rules { 
        stateless = false
        source = "10.0.0.0/16"
        source_type = "CIDR_BLOCK"
        protocol = "all"
    }

    ingress_security_rules { 
        stateless = false
        source = "10.200.0.0/16"
        source_type = "CIDR_BLOCK"
        protocol = "all"
    }

    ingress_security_rules { 
        stateless = false
        source = var.mine_home
        source_type = "CIDR_BLOCK"
        protocol = "6"
        tcp_options { 
            min = 22
            max = 22
        }
    }

    ingress_security_rules { 
        stateless = false
        source = var.mine_lab
        source_type = "CIDR_BLOCK"
        protocol = "6"
        tcp_options { 
            min = 22
            max = 22
        }
    }
}