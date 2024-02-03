# configure aws provider
provider "aws" {
  region    = var.region
  profile   = "terraform-user"
}

# create VPC
module "vpc" {
  source                            = "../modules/vpc"
  region                            =  var.region 
  project_name                      =  var.project_name
  vpc_cidr                          = var.vpc_cidr
  public_subnet_az1_cidr            = var.public_subnet_az1_cidr
  public_subnet_az2_cidr            = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr       = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr       = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr      = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr      = var.private_data_subnet_az2_cidr
}

# create nat gateways
module "nat_gateway" {
  source = "../modules/nat-gateway" 
  public_subnet_az1_id        = module.vpc.public_subnet_az1_id
  internet_gateway            = module.vpc.internet_gateway
  public_subnet_az2_id        = module.vpc.public_subnet_az2_id
  vpc_id                      = module.vpc.vpc_id
  private_app_subnet_az1_id   = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id  = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id   = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id  = module.vpc.private_data_subnet_az2_id

}

# security groups
module "security_group" {
  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id
  http-port = var.http-port
  https-port = var.https-port
  ssh-port = var.ssh-port
}

# data "associate_public_ip_address" "id" {
#   name = "pubic_ip"
# }



# create ec2
module "ec2_instance" {
  source                            = "../modules/ec2"       
  ami                               =  "data.aws_ami.amazon_linux_2"
  instance-type                     =  var.instance-type
  key_name                          =  var.key_name
  # ec2_security_group                =  module.security_group
  # subnet_id = module.var.public_subnet_az1_cidr.id
  # public_subnet_az1_id        = module.vpc.public_subnet_az1_id
  associate_public_ip_address = var.associate_public_ip_address
  # vpc_subnet_id = module.vpc.public_subnet_az2_id
  depends_on = [
    module.vpc
  ]
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Downloads/testposi.pem")
    host        = module.vpc.public_subnet_az1_id
  }

  # copy the script.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "./script.sh"
    destination = "/home/ec2-user/script.sh"
  }

  # set permissions and run the script.sh file
  provisioner "remote-exec" {
    inline = [
        "sudo chmod +x /home/ec2-user/script.sh",
        "sh /home/ec2-user/script.sh"
    ]
  }

  # wait for ec2 to be created
  depends_on = [module.ec2_instance]
}

