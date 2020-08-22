provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "build" {
  ami = "ami-0bcc094591f354be2"
  instance_type = "t2.micro"
  key_name = "ansible"
  security_groups = ["full_access"]
  subnet_id = "subnet-8f7f0ec2"
  associate_public_ip_address = true
  tags = {
    Name = "build"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y git default-jdk maven awscli",
      "git clone https://github.com/Galend-E/boxfuse.git /home/boxfuse",
      "cd /home/boxfuse",
      "mvn package"]
    connection {
      timeout = "5m"
      user = "ubuntu"
    }
  }
}

resource "aws_s3_bucket_object" "war" {
  bucket = "bak-01.train.com"
  key = "hello.war"
  source = "/home/boxfuse/target/hello-1.0.war"
  etag = filemd5("/home/boxfuse/target/hello-1.0.war")
}