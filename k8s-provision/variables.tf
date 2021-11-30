# provider variables
variable "tenancy_id" {
    type = string
}
variable "user_id" {
    type = string
}
variable "sandbox_id" {
    type = string
}
variable "api_key" {
    type = string
}
variable "api_fingerprint" {
    type = string
}
variable "region" {
    type = string
}
# security list variables
variable "mine_home" {
    type = string
}
variable "mine_lab" {
    type = string
}
# vm image variables
variable "os_name" {
    type = string
}
variable "os_version" {
    type = string
}
# vm variables
variable "worker_size" {
    type = number
    default = 1
}
variable "controller_size" {
    type = number
    default = 1
}
variable "ssh_key" {
    type = string
}