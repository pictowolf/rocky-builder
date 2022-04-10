variable "version" {
  type        = string
  default     = "0.0.1"
  description = "Version of the image"
}
variable "hostname" {
  type        = string
  default     = "test-host.localdomain"
  description = "Hostname of the image"
}
variable "root_pass" {
  type        = string
  default     = "root"
  description = "Root password of the image"
}
variable "cpus" {
  type        = number
  default     = 2
  description = "Number of CPUs"
}
variable "memory" {
  type        = number
  default     = 2048
  description = "Memory size in MB"
}
variable "iso" {
  type        = string
  default     = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.5-x86_64-minimal.iso"
  description = "ISO image to use"
}
variable "iso_checksum" {
  type        = string
  default     = "4eb2ae6b06876205f2209e4504110fe4115b37540c21ecfbbc0ebc11084cb779"
  description = "Checksum of the ISO image"
}
variable "ansible_playbook" {
  type        = string
  default     = "packer/ansible/playbook.yml"
  description = "Ansible playbook to use"
}
variable "ansible_roles" {
  type        = string
  default     = null
  description = "Ansible role requirements file"
}

source "hyperv-iso" "hypver-v" {
  vm_name      = "rockylinux8-${var.version}"
  cpus         = "${var.cpus}"
  memory       = "${var.memory}"
  ssh_username = "root"
  ssh_password = "${var.root_pass}"

  http_content = {
    "/ks.cfg" = templatefile("scripts/ks.pkrtpl",
    { hostname = "${var.hostname}", root_password = "${var.root_pass}" })
  }

  boot_command = [
    "<up><tab>",
    "text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter><wait><enter>",
  ]

  headless         = true
  shutdown_command = "/sbin/halt -h -p"
  iso_url          = "${var.iso}"
  iso_checksum     = "${var.iso_checksum}"
}

build {
  sources = ["source.hyperv-iso.hypver-v"]

  provisioner "ansible-local" {
    playbook_file = "${var.ansible_playbook}"
    galaxy_file   = "${var.ansible_roles}"
  }

  provisioner "shell" {
    execute_command   = "bash '{{ .Path }}'"
    expect_disconnect = true
    script            = "packer/scripts/bootstrap.sh"
  }
}