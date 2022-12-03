resource "aws_lb" "k8s_elb" {
    name = "kubernetes"
    internal = false
    load_balancer_type = "network"
    subnets = ["${aws_subnet.k8s_subnet.id}"]

    tags = {
        Name = "kubernetes"
    }
}

resource "aws_lb_target_group" "k8s_elb_group" {
    name  = "kubernetes"
    port  = 6443
    protocol = "TCP"
    target_type = "ip"
    vpc_id = "${aws_vpc.k8s_vpc.id}"
}

resource "aws_lb_target_group_attachment" "k8s_elb_group_attach" {
    count = "${var.controller_num}"

    target_group_arn = "${aws_lb_target_group.k8s_elb_group.arn}"
    target_id = "${var.controller_ips[count.index]}"
}

resource "aws_lb_listener" "k8s_elb_listener" {
    load_balancer_arn = "${aws_lb.k8s_elb.arn}"
    port = 443
    protocol = "TCP"

    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.k8s_elb_group.arn}"
    }
}
