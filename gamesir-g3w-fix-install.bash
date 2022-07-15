#!/bin/bash

set -e

INSTALL_PREFIX="/usr/local/bin"
GAMESIR_G3W_FIX_SCRIPT="$INSTALL_PREFIX/gamesir-g3w-fix.py"

# Output of lsusb|grep 360 for a Gamesir G3w is:
# Bus 001 Device 049: ID 045e:028e Microsoft Corp. Xbox360 Controller
VENDOR_ID=045e
PRODUCT_ID=028e

install_dependencies() {
  if which dpkg > /dev/null; then
    # Install the system package for pyusb on Debian,Ubuntu and derived distros.
    if ! dpkg -S python3-usb; then
      echo "Installing python3-usb with apt"
      sudo apt install -y python3-usb
    fi
  else
    # Install the pip package for pyusb on non-Debian distros.
    echo "Installing pyusb with pip"
    sudo pip install pyusb
  fi
}

install_gamesir_g3w_fix() {

  echo "Creating fix script for Gamesir G3w in $GAMESIR_G3W_FIX_SCRIPT"

  if [ ! -d "$INSTALL_PREFIX" ]; then
    sudo mkdir -pv $INSTALL_PREFIX
  fi

  sudo tee "$GAMESIR_G3W_FIX_SCRIPT" > /dev/null << EOF
#!/usr/bin/python3

# Script found on the first post in https://github.com/paroj/xpad/issues/119

import os
import sys

try:
    import usb.core
    import usb.util
except ImportError:
    print("First, install the pyusb module with PIP or your package manager.")
else:
    if os.geteuid() != 0:
        print("You need to run this script with sudo")
        sys.exit()

    dev = usb.core.find(find_all=True)

    for d in dev:
        if d.idVendor == 0x${VENDOR_ID} and d.idProduct == 0x${PRODUCT_ID}:
            d.ctrl_transfer(0xc1, 0x01, 0x0100, 0x00, 0x14)
finally:
    sys.exit()

EOF

  sudo chmod +x "$GAMESIR_G3W_FIX_SCRIPT"

}

install_udev_rules() {

  echo "Creating udev rules in /etc/udev/rules.d/99-gamesir-g3w-fix.rules"

  sudo tee /etc/udev/rules.d/99-gamesir-g3w-fix.rules > /dev/null << EOF
ACTION=="add", ATTRS{idProduct}=="${PRODUCT_ID}", ATTRS{idVendor}=="${VENDOR_ID}", DRIVERS=="usb", RUN+="$GAMESIR_G3W_FIX_SCRIPT"

EOF

  echo "Restarting systemd-udevd"

  sudo systemctl restart systemd-udevd.service

}

install_dependencies

# Install Gamesir G3w fix script
install_gamesir_g3w_fix

# Install udev rules
install_udev_rules

# Run the script once so if there are any errors, they are displayed
echo "Executing $GAMESIR_G3W_FIX_SCRIPT"
sudo $GAMESIR_G3W_FIX_SCRIPT

echo "Done."

