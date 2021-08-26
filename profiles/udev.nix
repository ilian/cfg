{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="122[27]|128[0-3]", TAG+="uaccess", TAG+="udev-acl"
  '';
}
