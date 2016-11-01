variable "image_id"  {
  default = "ami-746aba14"
}

variable "controller_instance_ips" { 
  default = {
    "0" = "10.240.0.10"
    "1" = "10.240.0.11"
    "2" = "10.240.0.12"
  }
}

variable  "controller_instance_names" {
  default = {
    "0" = "controller0"
    "1" = "controller1"
    "2" = "controller2"
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

