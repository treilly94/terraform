variable "region" {}
variable "amis" {
  type = "map"
}

provider "aws" {
	region = "${var.region}"
}

resource "aws_instance" "example" {
  	ami           = "${lookup(var.amis, var.region)}"
	instance_type = "t2.micro"

	key_name = "example_kp"

	provisioner "local-exec" {
		command = "echo ${aws_instance.example.public_dns} > ip_address.txt"
	}

	tags {
    	Name = "Example"
  	}
}


output "ip" {
  value = "${aws_instance.example.public_dns}"
}