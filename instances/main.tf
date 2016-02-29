# Key Pair
resource "aws_key_pair" "auth" {
  key_name = "${var.public_key_name}"
  public_key = "${file(var.public_key_path)}"
}

# EC2
resource "aws_instance" "web" {
  connection {
    user = "ubuntu"
  }

  instance_type = "m1.micro"

  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start"
    ]
  }
}
