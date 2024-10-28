
variable "project" {
  description = "Name of the project variable"
  type        = string
  default     = "lab-002"
}
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
  sensitive   = true
}

#$env:TF_VAR_access_key = "your-access-key"
#Write-Host $env:TF_VAR_access_key


