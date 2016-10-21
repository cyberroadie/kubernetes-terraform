# Configure the AWS Provider
provider "aws" {
    # export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as environment variables
    # or add them here:
    # access_key = "${var.aws_access_key}"
    # secret_key = "${var.aws_secret_key}"
    region = "us-west-2"
}

resource "aws_instance" "web" {
    associate_public_ip_address = true
    iam_instance_profile = 
    ami = "${var.image_id}"  
    instance_type = "t2.small"
    tags {
        Name = "HelloWorld"
    }
}
