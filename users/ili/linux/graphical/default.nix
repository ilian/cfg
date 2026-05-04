{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      firefox
      chromium
      thunderbird
      libreoffice
      remmina
      helvum # pipewire patchbay
      pdfpc # PDF Presentation
      xclip
      mesa-demos # glxinfo
      ffmpeg-full # ffplay
      jetbrains-toolbox
    ];
  };

  fonts.fontconfig.enable = true;

  # TODO: Requires xession setup by HM?
  # home.keyboard = {
  #   options = [ "ctrl:swapcaps" ];
  # };
}
