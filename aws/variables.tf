variable "architecture" {
  type        = string
  description = "Architecture of developer instance."
  default     = "arm64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "The architecture must be either x86_64 or arm64."
  }
}

