# Configure the AWS Provider
provider "aws" {
    # export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as environment variables
    # or add them here:
    # access_key = "${var.aws_access_key}"
    # secret_key = "${var.aws_secret_key}"
    region = "us-west-2"
}

# aws ec2 create-vpc \
#   --cidr-block 10.240.0.0/16 | \
#   jq -r '.Vpc.VpcId'
resource "aws_vpc" "orchestration_vpc" {
    cidr_block = "10.240.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "kubernetes.dev"
    }
}

# DHCP_OPTION_SET_ID=$(aws ec2 create-dhcp-options \
#   --dhcp-configuration "Key=domain-name,Values=us-west-2.compute.internal" \
#     "Key=domain-name-servers,Values=AmazonProvidedDNS" | \
#   jq -r '.DhcpOptions.DhcpOptionsId')
# 
# aws ec2 create-tags \
#   --resources ${DHCP_OPTION_SET_ID} \
#   --tags Key=Name,Value=kubernetes
resource "aws_vpc_dhcp_options" "orchestration_dhcp" {
    domain_name = "us-west-2.compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]

    tags {
        Name = "kubernetes.dev"
    }
}

# aws ec2 associate-dhcp-options \
#   --dhcp-options-id ${DHCP_OPTION_SET_ID} \
#   --vpc-id ${VPC_ID}
resource "aws_vpc_dhcp_options_association" "orchestration_dns_resolver" {
    vpc_id = "${aws_vpc.orchestration_vpc.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.orchestration_dhcp.id}"
}

# SUBNET_ID=$(aws ec2 create-subnet \
#   --vpc-id ${VPC_ID} \
#   --cidr-block 10.240.0.0/24 | \
#   jq -r '.Subnet.SubnetId')
#
# aws ec2 create-tags \
#   --resources ${SUBNET_ID} \
#   --tags Key=Name,Value=kubernetes
resource "aws_subnet" "orchestration_subnet" {
  vpc_id = "${aws_vpc.orchestration_vpc.id}"
  cidr_block = "10.240.0.0/24"

  tags {
        Name = "kubernetes.dev"
  }
}

# INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway | \
#   jq -r '.InternetGateway.InternetGatewayId')
# aws ec2 create-tags \
#   --resources ${INTERNET_GATEWAY_ID} \
#   --tags Key=Name,Value=kubernetes
# aws ec2 attach-internet-gateway \
#   --internet-gateway-id ${INTERNET_GATEWAY_ID} \
#   --vpc-id ${VPC_ID}
resource "aws_internet_gateway" "orchestration_gw" {
    vpc_id = "${aws_vpc.orchestration_vpc.id}"

    tags {
        Name = "kubernetes.dev"
    }
}

# ROUTE_TABLE_ID=$(aws ec2 create-route-table \
#   --vpc-id ${VPC_ID} | \
#   jq -r '.RouteTable.RouteTableId')
# aws ec2 create-tags \
#   --resources ${ROUTE_TABLE_ID} \
#   --tags Key=Name,Value=kubernetes
resource "aws_route_table" "orchestration_rt" {
    vpc_id = "${aws_vpc.orchestration_vpc.id}"

    tags {
        Name = "kubernetes.dev"
    }
}

# aws ec2 associate-route-table \
#   --route-table-id ${ROUTE_TABLE_ID} \
#   --subnet-id ${SUBNET_ID}
resource "aws_route_table_association" "orchestration_a" {
    subnet_id = "${aws_subnet.orchestration_subnet.id}"
    route_table_id = "${aws_route_table.orchestration_rt.id}"
}

# aws ec2 create-route \
#   --route-table-id ${ROUTE_TABLE_ID} \
#   --destination-cidr-block 0.0.0.0/0 \
#   --gateway-id ${INTERNET_GATEWAY_ID}
resource "aws_route" "orchestration_r" {
    route_table_id = "${aws_route_table.orchestration_rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.orchestration_gw.id}"
}

# SECURITY_GROUP_ID=$(aws ec2 create-security-group \
#   --group-name kubernetes \
#   --description "Kubernetes security group" \
#   --vpc-id ${VPC_ID} | \
#   jq -r '.GroupId')
# aws ec2 create-tags \
#   --resources ${SECURITY_GROUP_ID} \
#   --tags Key=Name,Value=kubernetes
#
# aws ec2 authorize-security-group-ingress \
#   --group-id ${SECURITY_GROUP_ID} \
#   --protocol all \
#   --source-group ${SECURITY_GROUP_ID}
resource "aws_security_group" "orchestration_fw" {
    name = "kubernetes"
    description = "Kubernetes security group"
    vpc_id = "${aws_vpc.orchestration_vpc.id}"

    # aws ec2 authorize-security-group-ingress \
    #   --group-id ${SECURITY_GROUP_ID} \
    #   --protocol all
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # aws ec2 authorize-security-group-ingress \
    #   --group-id ${SECURITY_GROUP_ID} \
    #   --protocol all \
    #   --port 0-65535 \
    #   --cidr 10.240.0.0/16
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.240.0.0/16"]
    }

    # aws ec2 authorize-security-group-ingress \
    #   --group-id ${SECURITY_GROUP_ID} \
    #   --protocol tcp \
    #   --port 22 \
    #   --cidr 0.0.0.0/0
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # aws ec2 authorize-security-group-ingress \
    #   --group-id ${SECURITY_GROUP_ID} \
    #   --protocol tcp \
    #   --port 6443 \
    #   --cidr 0.0.0.0/0    
    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"   
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
            Name = "kubernetes.dev"
    }
}


# aws elb create-load-balancer \
#   --load-balancer-name kubernetes \
#   --listeners "Protocol=TCP,LoadBalancerPort=6443,InstanceProtocol=TCP,InstancePort=6443" \
#   --subnets ${SUBNET_ID} \
#   --security-groups ${SECURITY_GROUP_ID}
resource "aws_elb" "orchestration_fw_elb" {
    name = "kubernetes"

    listener {
        lb_protocol = "tcp"
        lb_port = 6443
        instance_protocol = "tcp"
        instance_port = "6443"
    }

    subnets = ["${aws_subnet.orchestration_subnet.id}"]
    security_groups = ["${aws_security_group.orchestration_fw.id}"]

}

# cat > kubernetes-iam-role.json <<'EOF'
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {"Effect": "Allow", "Principal": { "Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}
#   ]
# }
# EOF
# aws iam create-role \
#   --role-name kubernetes \
#   --assume-role-policy-document file://kubernetes-iam-role.json
resource "aws_iam_role" "orchestration_role" {
    name = "kubernetes"
    assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Principal": { "Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}
  ]
}
EOF
}

# cat > kubernetes-iam-policy.json <<'EOF'
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {"Effect": "Allow", "Action": ["ec2:*"], "Resource": ["*"]},
#     {"Effect": "Allow", "Action": ["elasticloadbalancing:*"], "Resource": ["*"]},
#     {"Effect": "Allow", "Action": ["route53:*"], "Resource": ["*"]},
#     {"Effect": "Allow", "Action": ["ecr:*"], "Resource": "*"}
#   ]
# }
# EOF
# aws iam put-role-policy \
#   --role-name kubernetes \
#   --policy-name kubernetes \
#   --policy-document file://kubernetes-iam-policy.json
resource "aws_iam_role_policy" "orchestration_policy" {
    name = "kubernetes"
    role = "${aws_iam_role.orchestration_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Action": ["ec2:*"], "Resource": ["*"]},
    {"Effect": "Allow", "Action": ["elasticloadbalancing:*"], "Resource": ["*"]},
    {"Effect": "Allow", "Action": ["route53:*"], "Resource": ["*"]},
    {"Effect": "Allow", "Action": ["ecr:*"], "Resource": "*"}
  ]
}
EOF
}

# aws iam create-instance-profile \
#   --instance-profile-name kubernetes 
#
# aws iam add-role-to-instance-profile \
#   --instance-profile-name kubernetes \
#   --role-name kubernetes
resource "aws_iam_instance_profile" "orchestration_profile" {
    name = "kubernetes"
    roles = ["kubernetes"]
}

# aws ec2 create-key-pair --key-name kubernetes | \
#   jq -r '.KeyMaterial' > ~/.ssh/kubernetes_the_hard_way
# chmod 600 ~/.ssh/kubernetes_the_hard_way
# ssh-add ~/.ssh/kubernetes_the_hard_way 
#
# WARNING: Terraform can not create key-pairs
# instead we create a key via the web interface:
# https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:sort=keyName
# 
# download the key and create a public key:
# chmod 0600 ../kubernetes.pem 
# ssh-keygen -y -f ../kubernetes.pem > ../kubernetes.pub 
# ssh-add ../kubernetes.pem
resource "aws_key_pair" "orchestration_key" {
  key_name = "kubernetes" 
  public_key = "${file("kubernetes.pub")}"
}

# 3 controllers
#
# CONTROLLER_1_INSTANCE_ID=$(aws ec2 run-instances \
#   --associate-public-ip-address \
#   --iam-instance-profile 'Name=kubernetes' \
#   --image-id ${IMAGE_ID} \
#   --count 1 \
#   --key-name kubernetes \
#   --security-group-ids ${SECURITY_GROUP_ID} \
#   --instance-type t2.small \
#   --private-ip-address 10.240.0.11 \
#   --subnet-id ${SUBNET_ID} | \
#   jq -r '.Instances[].InstanceId')
# aws ec2 modify-instance-attribute \
#   --instance-id ${CONTROLLER_1_INSTANCE_ID} \
#   --no-source-dest-check
# aws ec2 create-tags \
#   --resources ${CONTROLLER_1_INSTANCE_ID} \
#   --tags Key=Name,Value=controller1
resource "aws_instance" "orchestration_control" {
    count = 3
    associate_public_ip_address = true
    iam_instance_profile = "kubernetes"
    ami = "${var.image_id}" 
    key_name = "kubernetes"
    security_groups = ["${aws_security_group.orchestration_fw.id}"]
    instance_type = "t2.small"
    private_ip = "${element(values(var.controller_instance_ips), count.index)}"
    subnet_id = "${aws_subnet.orchestration_subnet.id}"
    source_dest_check = false
    tags {
        Name = "${element(values(var.controller_instance_names), count.index)}"
    }

    # Install Python so we can run ansible. Go is always good to have too.
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get update -y",
            "sudo apt-get -y install python golang"
        ]

        connection {
           user = "ubuntu"
           private_key = "${file("kubernetes.pem")}"
        }

    }

}

# 3 workers
#
# WORKER_0_INSTANCE_ID=$(aws ec2 run-instances \
#   --associate-public-ip-address \
#   --iam-instance-profile 'Name=kubernetes' \
#   --image-id ${IMAGE_ID} \
#   --count 1 \
#   --key-name kubernetes \
#   --security-group-ids ${SECURITY_GROUP_ID} \
#   --instance-type t2.small \
#   --private-ip-address 10.240.0.20 \
#   --subnet-id ${SUBNET_ID} | \
#   jq -r '.Instances[].InstanceId')
# aws ec2 modify-instance-attribute \
#   --instance-id ${WORKER_0_INSTANCE_ID} \
#   --no-source-dest-check
# aws ec2 create-tags \
#   --resources ${WORKER_0_INSTANCE_ID} \
#   --tags Key=Name,Value=worker0
resource "aws_instance" "orchestration_worker" {
    count = 3
    associate_public_ip_address = true
    iam_instance_profile = "kubernetes"
    ami = "${var.image_id}" 
    key_name = "kubernetes"
    security_groups = ["${aws_security_group.orchestration_fw.id}"]
    instance_type = "t2.small"
    private_ip = "${element(values(var.worker_instance_ips), count.index)}"
    subnet_id = "${aws_subnet.orchestration_subnet.id}"
    source_dest_check = false
    tags {
        Name = "${element(values(var.worker_instance_names), count.index)}"
    }

    # Install Python so we can run ansible. Go is always good to have too.
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get update -y",
            "sudo apt-get -y install python golang"
        ]

        connection {
           user = "ubuntu"
           private_key = "${file("kubernetes.pem")}"
        }
    }
}
