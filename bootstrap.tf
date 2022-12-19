terraform {
  required_providers {
    installer = {
      source  = "shihanng/installer"
      version = "0.3.0"
    }
  }
}

provider "installer" {
  # Configuration options
}

resource "installer_apt" "emacs" {
  name     = "emacs"
}

resource "installer_apt" "net-tools" {
  name     = "net-tools"
}