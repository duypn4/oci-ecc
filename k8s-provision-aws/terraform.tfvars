region = "us-east-1"
profile = "default"
vpc_cidr = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"
controller_ips = ["10.0.1.10", "10.0.1.11", "10.0.1.12"]
controller_num = 1
worker_ips = ["10.0.1.20", "10.0.1.21", "10.0.1.22"]
worker_num = 2
ec2_type = "t2.medium"
key_pair = "kubernetes"