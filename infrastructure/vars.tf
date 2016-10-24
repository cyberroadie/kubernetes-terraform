variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT3+M6HxfarenN84QSW/nuYUVmvUNxcW7NlisvoE+jTd+rVDml0wuB/cguDaxThw2t0ee07T++lpPIlzAXlW1vY3h5DDVw26rgoZVHEWQa5sD96mjwJL4Ip7D8+wtumyTAP7yfuXGv6qjLguoh6cJ6WYyKuYMvXrZZu49ZAPA7fTck4Tb+2Y/jS+16M9g4NvnprOFu0yjm6QcWGxPvvEUoa42kCedUw6/c+fAZir6/mqYZnNp/4wWgrbDG+pwV2dBRES9Ieqlg8oOgkdzo9vXzV3Vm3bULBr5HHOdYONpDM8m1MlBeXjSL7/9So672JR3GN0sMImQNy89j0K9Zp5t3"
}

variable "image_id"  {
  default = "ami-746aba14"
}

variable "controller_instance_ips" { 
  default = {
    "0" = "10.240.0.11"
    "1" = "10.240.0.12"
  }
}

variable  "controller_instance_names" {
  default = {
    "0" = "controller1"
    "1" = "controller2"
  }
}

variable "worker_instance_ips" {
  default = {
    "0" = "10.240.0.20"
    "1" = "10.240.0.21"
    "2" = "10.240.0.22"
  }
}

variable "worker_instance_names" {
  default = {
    "0" = "worker0"
    "1" = "worker1"
    "2" = "worker2"
  }
}

