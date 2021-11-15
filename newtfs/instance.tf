/*
  -----------------------------------------------------------------------------
                          Initialize/Declare Variables
  -----------------------------------------------------------------------------
*/
#resource "aws_route53_zone" "test" {
#  name = "yo.${var.dns_zone}"
#}
#
#resource "aws_route53_record" "www" {
#  zone_id = aws_route53_zone.test.zone_id
#  name    = "www.${aws_route53_zone.test.name}"
#  type    = "A"
#  ttl     = "300"
#  records = [aws_instance.web.public_ip]
#}
#
#resource "aws_route53_record" "user-dev" {
#  zone_id = aws_route53_zone.test.zone_id
#  name    = "dev"
#  type    = "CNAME"
#  ttl     = "5"
#
#  weighted_routing_policy {
#    weight = 10
#  }
#
#  set_identifier = "devs"
#  records        = ["user-dev"]
#}

/*
  -----------------------------------------------------------------------------
                                  EC2 Instance
  # Create a new instance of the latest Ubuntu 14.04 on an
  # t3.small node with an AWS Tag naming it "HelloWorld"
  -----------------------------------------------------------------------------
*/
resource "aws_instance" "test_instance" {
  ami = data.aws_ami.test_ami.id
  #count                  = 2
  #key_name               = "tthomas.pub" # Comment this line for demo drama
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.ssh-ports.id]
  ipv6_address_count     = 1

  subnet_id                   = var.subnet
  associate_public_ip_address = true
  hibernation                 = false

  tags = {
    Name = "tf-demo-test"
  }
}

# -----------------------------------------------------------------------------
# Create a Security Group for the Instance
# -----------------------------------------------------------------------------
resource "aws_security_group" "ssh-ports" {
  name   = "ssh-inbound"
  vpc_id = var.vpc_network
  # Inbound SSH from myOffice
  ingress {
    description = "Inbound from Home Office / TESTING ONLY"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.officeIPAddr]
  }
  ingress {
    description = "IPv4 ICMP TESTING-ONLY - DELETE AFTER USE"
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    self        = true
  }
  ingress {
    description = "IPv6 ICMP TESTING-ONLY - DELETE AFTER USE"
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmpv6"
    self        = true
  }
  # Allow all outbound traffic: for now
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# -----------------------------------------------------------------------------
# Find the latest AMI; NOTE: MUST produce only 1 AMI ID.
# -----------------------------------------------------------------------------
data "aws_ami" "test_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["golden-amazonlinux"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"] # points to my aws account number
}
