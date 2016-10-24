public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMm1JbbjnE5nBTKxyzFCaBQEGo81H0aGjMDgsI8qAwCByuOlI9WOMBVDI+sub//XZoWluxVe94keFi+6+OuouU0NcgjXXNS3Iq1XP5F1fC79xUeqtv4BeppcPFLrgg0hpWfO1QYOx2xuOUhx9WemmN/5NASylfC/BbRdHEuzcklDPkx8Cvys7sWQ8ExRMgBGQ2DJKLBJKobu7OkhHz0DcMRT06QXt6FtyMAKduF7G2NEgNpMc3fH7cI5XoUZJF05G8h3swUwI1uUAj7mKa/bRiREdy5Y8y2l1AsUz/i0wyNPrCUiDUab/xyELN8HI0/dSF769BcAXOGlmAfEo33tMV cyberroadie@laptop.local"

image_id =  "ami-746aba14"

variable "controller_instance_ips" {
  default = {
    "0" = "10.240.0.11"
    "1" = "10.240.0.12"
  }
}

variable "controller_instance_names" {
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

