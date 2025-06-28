{ pkgs, ... }:

{
  services.usbmuxd.enable = true;
  # DFU mode
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="122[27]|128[0-3]", TAG+="uaccess", TAG+="udev-acl"
  '';

  environment.systemPackages = with pkgs; [
    libimobiledevice # idevicesyslog
    ifuse # copying files never has been this easy!
  ];
}
