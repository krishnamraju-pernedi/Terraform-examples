variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "elb_port" {
  type        = number
  default     = 80
  description = "ELB accessible port"
}

variable "ec2_image_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}

variable "elb_name" {
  type = string
}