resource "oci_core_instance" "controller-nodes" {
    count = var.controller_size

    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.compartment.id
    shape = "VM.Standard.E2.1"
    source_details {
        source_id = data.oci_core_images.ubuntu.images[0].id
        source_type = "image"
    }
    display_name = "controller-${count.index}"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.public-subnet.id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_key)
    }
    preserve_boot_volume = false
}

resource "oci_core_instance" "worker-nodes" {
    count = var.worker_size

    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.compartment.id
    shape = "VM.Standard.E2.1"
    source_details {
        source_id = data.oci_core_images.ubuntu.images[0].id
        source_type = "image"
    }
    display_name = "worker-${count.index}"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.public-subnet.id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_key)
    }
    preserve_boot_volume = false
}