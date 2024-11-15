variable "tag_environment" {
  description = "The name of the environment to use in resource tagging"
  type        = string
}

variable "tag_name" {
  description = "The name tag of the instance"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The subnet to use for the instance"
  type        = string
}

variable "size" {
  description = "The size of the instance to use"
  type        = string
}

variable "source_image_id" {
  description = "The Image ID to use for the VM"
  type        = string
  default     = null
}

variable "hostname" {
  description = "The hostname of the instance"
  type        = string
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "raid_array_size" {
  description = "Size in GB of RAID array"
  type        = number
  default     = 0
}

variable "root_volume_size" {
  description = "Size in GB of RAID array"
  type        = number
  default     = 30
}

variable "additional_volumes" {
  description = "Additional volumes to create and attach to the instance"
  type        = map(map(string))
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group to use"
  type        = string
}

variable "location" {
  description = "The location to use for the instance"
  type        = string
}

variable "ssh_public_key" {
  description = "The SSH public key to use for the instance"
  type        = string
}

variable "priority" {
  description = "The priority of the instance"
  type        = string
  default     = "Regular"
}

variable "source_image_reference" {
  description = "The source image reference to use for the instance"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to use for the instance"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "The admin username to use for the instance"
  type        = string
  default     = "adminuser"
}

variable "identity" {
  description = "Specifies the identity block for the instance."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}
