variable "region" {
    type = "string"
}

variable "profile" {
    type = "string"
}

variable "vpc_cidr" {
    type = "string"
}

variable "subnet_cidr" {
    type = "string"
}

variable "controller_ips" {
    type = "list"
}

variable "controller_num" {
    type = "string"
}


variable "worker_ips" {
    type = "list"
}

variable "worker_num" {
    type = "string"
}

variable "ec2_type" {
    type = "string"
}

variable "key_pair" {
    type = "string"  
}







