data "aws_ami" "k8s_ami" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

resource "aws_instance" "k8s_controller" {
    count = "${var.controller_num}"

    ami = "${data.aws_ami.k8s_ami.id}"
    instance_type = "${var.ec2_type}"
    associate_public_ip_address = true
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.k8s_sg.id}"]
    private_ip = "${var.controller_ips[count.index]}"
    user_data = <<EOF
    #!/bin/bash
    name=controller-${count.index}
    EOF
    subnet_id = "${aws_subnet.k8s_subnet.id}"
    ebs_block_device {
        device_name = "/dev/sda1"
        volume_size = 8
    }
    source_dest_check = false

    tags = {
        Name = "controller-${count.index}"
    }
}

resource "aws_instance" "k8s_worker" {
    count = "${var.worker_num}"

    ami = "${data.aws_ami.k8s_ami.id}"
    instance_type = "${var.ec2_type}"
    associate_public_ip_address = true
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.k8s_sg.id}"]
    private_ip = "${var.worker_ips[count.index]}"
    user_data = "name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24"
    subnet_id = "${aws_subnet.k8s_subnet.id}"
    ebs_block_device {
        device_name = "/dev/sda1"
        volume_size = 8
    }
    source_dest_check = false

    tags = {
        Name = "worker-${count.index}"
    }
}



