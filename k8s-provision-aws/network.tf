resource "aws_vpc" "k8s_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "kubernetes"
    }
}

resource "aws_subnet" "k8s_subnet" {
    vpc_id = "${aws_vpc.k8s_vpc.id}"
    cidr_block = "${var.subnet_cidr}"

    tags = {
        Name = "kubernetes"
    }
}

resource "aws_internet_gateway" "k8s_igw" {
    vpc_id = "${aws_vpc.k8s_vpc.id}"

    tags = {
        Name = "kubernetes"
    }
}

resource "aws_route_table" "k8s_rtb" {
    vpc_id = "${aws_vpc.k8s_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.k8s_igw.id}"
    }

    tags = {
        Name = "kubernetes"
    }
}

resource "aws_route_table_association" "k8s_rtb_attach" {  
    subnet_id = "${aws_subnet.k8s_subnet.id}"
    route_table_id = "${aws_route_table.k8s_rtb.id}"
}

resource "aws_security_group" "k8s_sg" {
    name = "k8s_sg"
    description = "Kubernetes security group"
    vpc_id = "${aws_vpc.k8s_vpc.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${aws_vpc.k8s_vpc.cidr_block}", "10.200.0.0/16"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "kubernetes"
    }
}

