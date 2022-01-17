variable "ami" {
  description = "Amazon Machine Image for developer instance."
  type        = object({ id = string, architecture = string })
}

variable "ssh_public_key" {
  description = "SSH public key for instance access."
  type        = string
}

