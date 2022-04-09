variable "version" {
  type    = string
  default = "0.0.1"
}

variable "hostname" {
  type    = string
  default = "test-host.localdomain"
}

variable "root_pass" {
  type    = string
  default = "root"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "iso" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.5-x86_64-minimal.iso"
}

variable "iso_checksum" {
  type    = string
  default = "4eb2ae6b06876205f2209e4504110fe4115b37540c21ecfbbc0ebc11084cb779"
}

source "hyperv-iso" "hypver-v" {
  vm_name      = "rockylinux8-${var.version}"
  cpus         = "${var.cpus}"
  memory       = "${var.memory}"
  ssh_username = "root"
  ssh_password = "${var.root_pass}"
  http_content = {
    "/ks.cfg" = templatefile("scripts/ks.pkrtpl", { hostname = "${var.hostname}", root_password = "${var.root_pass}" })
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

  provisioner "shell" {
    execute_command   = "bash '{{ .Path }}'"
    expect_disconnect = true
    script            = "packer/scripts/bootstrap.sh"
  }
}