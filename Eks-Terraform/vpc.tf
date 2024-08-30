resource "aws_vpc" "vp" {
tags = {
name = "three-tier.vpc"
}
cidr_block = "10.0.0.0/16"
instance_tenancy = "default"
enable_dns_hostnames = "true"
}

resource "aws_subnet" "sub1" {
tags = {
Name = "three-tier.subnet1"
}
vpc_id = aws_vpc.vp.id
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = "true"
availability_zone = "ap-south-1a"
}

resource "aws_subnet" "sub2" {
tags = {
Name = "three-tier.subnet2"
}
vpc_id = aws_vpc.vp.id
cidr_block = "10.0.2.0/24"
map_public_ip_on_launch = "true"
availability_zone = "ap-south-1b"
}

resource "aws_internet_gateway" "igw" {
tags = {
Name = "three-tier.igw"
}
vpc_id = aws_vpc.vp.id
}

resource "aws_route_table" "rt" {
tags = {
Name = "three-tier.routetable"
}
vpc_id = aws_vpc.vp.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
}

resource "aws_route_table_association" "rtc1" {
subnet_id = aws_subnet.sub1.id
route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rtc2" {
subnet_id = aws_subnet.sub2.id
route_table_id = aws_route_table.rt.id
}
