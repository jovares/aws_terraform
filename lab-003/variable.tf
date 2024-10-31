
variable "region" {
  description = "value"
  type        = string
  sensitive   = true
  default     = "us-east-1"
}
variable "access_key" {
  description = "value"
  type        = string
  sensitive   = true
}
variable "secret_key" {
  description = "value"
  type        = string
  sensitive   = true
}
variable "proyect" {
  description = "value of the proyect"
  type        = string
  default     = "lab-003"
}