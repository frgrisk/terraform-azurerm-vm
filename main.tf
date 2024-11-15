terraform {
  required_version = "~>1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

locals {
  tag_name = coalesce(var.tag_name, var.hostname)

  volume_mounts = join("\n", [
    for device, volume in var.additional_volumes :
    templatefile(
      "${path.module}/user_data_scripts/mount_volume.sh",
      {
        device      = device
        mount_point = volume.mount_point
      }
    )
    ]
  )

  user_data = join("\n", [
    var.user_data,
    file("${path.module}/user_data_scripts/reboot.sh")
    ]
  )

  instance_tags = merge(
    {
      Name        = local.tag_name
      Environment = var.tag_environment
      Hostname    = var.hostname
    },
    var.additional_tags,
  )
}

resource "azurerm_linux_virtual_machine" "instance" {
  name                = local.tag_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username

  priority        = var.priority
  eviction_policy = var.priority == "Spot" ? "Deallocate" : null

  network_interface_ids = [
    azurerm_network_interface.instance.id
  ]

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  tags = local.instance_tags

  custom_data = base64encode(
    local.volume_mounts == "" ? local.user_data : join("\n", [
      local.volume_mounts,
      local.user_data
    ])
  )

  source_image_id = var.source_image_id
  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.root_volume_size
  }
}

resource "azurerm_network_interface" "instance" {
  name                = "${local.tag_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = local.instance_tags
}

resource "azurerm_managed_disk" "additional" {
  for_each             = var.additional_volumes
  name                 = "${local.tag_name}-disk-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.size

  tags = local.instance_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "additional" {
  for_each           = azurerm_managed_disk.additional
  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_linux_virtual_machine.instance.id
  lun                = index(keys(var.additional_volumes), each.key)
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "raid_array" {
  count                = var.raid_array_size > 0 ? 10 : 0
  name                 = "${local.tag_name}-raid-disk-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.raid_array_size / 10

  tags = local.instance_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "raid_array" {
  count              = length(azurerm_managed_disk.raid_array)
  managed_disk_id    = azurerm_managed_disk.raid_array[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.instance.id
  lun                = count.index + 10
  caching            = "ReadWrite"
}
