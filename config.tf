provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "build" {
  ami = "ami-0bcc094591f354be2"
  instance_type = "t2.micro"
  key_name = "ansible"
  security_groups = ["sg-02cc480bb425000f4"]
  subnet_id = "subnet-8f7f0ec2"
  associate_public_ip_address = true
  tags = {
    Name = "build"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y git default-jdk maven",
      "sudo git clone https://github.com/Galend-E/boxfuse.git /home/boxfuse",
      "cd /home/boxfuse",
      "sudo mvn package",
      "curl -k -X PUT -T './target/hello-1.0.war' -H 'Host: buk-02.train.com.s3.amazonaws.com' -H 'Date: $(date -R)' -H 'Content-Type: application/java-archive' https://buk-02.train.com.s3.amazonaws.com/hello.war"
    ]
    connection {
      timeout = "5m"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}


