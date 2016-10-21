output "vpc_id" {
    value = "$aws_vpc.orchestration_vpc.id" 
}

output "dhcp_id_id" {
    value = "$aws_vpc_dhcp_options.orchestration_dhcp.id" 
}

output "subnet_id" {
    value = "$aws_subnet.orchestration_subnet.id" 
}
