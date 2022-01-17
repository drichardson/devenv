variable "architecture" {
  description = "Architecture of developer instance."
  type        = string

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "The architecture must be either x86_64 or arm64."
  }
}

variable "tags" {
  description = "Tags to set on resources"
  type        = map(string)
  default     = {}
}

