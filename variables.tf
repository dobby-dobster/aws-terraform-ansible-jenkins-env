variable "profile" {
  type    = string
  default = "default"
}

variable "dns-name" {
  type    = string
  default = "cmcloudlab694.info."
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "region-worker" {
  type    = string
  default = "us-west-2"
}

variable "workers-count" {
  type    = number
  default = 1
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}

variable "webserver-port" {
  type    = number
  default = 8080
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0" # your public IP to allow access to jenkins
}

