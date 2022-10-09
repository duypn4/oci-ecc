resource "oci_identity_compartment" "compartment" {
    compartment_id = var.root_compartment_id
    description = "Compartment for Coded Computing setup"
    name = var.compartment_name
}