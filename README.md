# kubernetes-terraform

## Prerequisites
### Software
* Ansible
* Terraform
* AWS Command Line Tools

### Create keypair
Terrafrom can not create a keypair automaticly so you have to do it yourself in the AWS web interface

### SSH (Optional)
In file `/etc/ssh/ssh_config` or `~/.ssh/config` add:
    StrictHostKeyChecking no
This will disable interactive prompts when logging into unknown hosts.

## Cloud Infrastructure Provisioning  
Set environment variables for accessing AWS:

    export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXX" 
    export AWS_SECRET_ACCESS_KEY="xXxXxxxxXxXXXxXxxxxXxxxXXxxXxXxxxXxxXxxx"
    export AWS_DEFAULT_REGION="us-west-2"

In `./infrastructure/vars.tf` change the public key and (optional) change the AMI id
the current AMI will only work in the us-west-2 zone

    variable "public_key" {
        default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT3+M6HxfarenN84QSW/nuYUVmvUNxcW7NlisvoE+jTd+rVDml0wuB/cguDaxThw2t0ee07T++lpPIlzAXlW1vY3h5DDVw26rgoZVHEWQa5sD96mjwJL4Ip7D8+wtumyTAP7yfuXGv6qjLguoh6cJ6WYyKuYMvXrZZu49ZAPA7fTck4Tb+2Y/jS+16M9g4NvnprOFu0yjm6QcWGxPvvEUoa42kCedUw6/c+fAZir6/mqYZnNp/4wWgrbDG+pwV2dBRES9Ieqlg8oOgkdzo9vXzV3Vm3bULBr5HHOdYONpDM8m1MlBeXjSL7/9So672JR3GN0sMImQNy89j0K9Zp5t3"
    }

    variable "image_id"  {
        default = "ami-746aba14"
    }

Run the scripts, plan first to check if everything works. Execute with apply

    $ cd infrastructure 
    $ terrafrom plan
    $ terraform apply

To get usefull info (like public IPs) run:

    $ terraform output -json

## Setting up a CA and TLS Cert Generation
Create Certificate Authority and Certificates

    $ ./01_create_ca.sh
    $ ./02_create_csr_json.sh
    $ ./03_create_cert.sh
    $ ./04_copy_cert_keys.sh

