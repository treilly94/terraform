variable "cluster-name" {
	default = "eks-test-cluster"
	type = "string"
}

provider "aws" {
	region = "us-east-1"
}

# Network
resource "aws_vpc" "default" {
	cidr_block = "10.0.0.0/16"

	tags = "${
		map(
			"Name", "eks-test-vpc",
			"kubernetes.io/cluster/${var.cluster-name}", "shared",
		)
	}"
}

resource "aws_subnet" "default" {
	count = 2

	cidr_block = "10.0.${count.index}.0/24"
	vpc_id = "${aws_vpc.default.id}"

	tags = "${
    	map(
     		"Name", "eks-test-subnet",
     		"kubernetes.io/cluster/${var.cluster-name}", "shared",
    	)
  	}"
}

resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.default.id}"

	tags {
		Name = "eks-test-gateway"
	}
}

resource "aws_route_table" "default" {
	vpc_id = "${aws_vpc.default.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}

	tags {
		Name = "eks-test-route-table"
	}
}

resource "aws_route_table_association" "demo" {
	count = 2

	subnet_id = "${aws_subnet.default.*.id[count.index]}"
	route_table_id = "${aws_route_table.default.id}"
}

