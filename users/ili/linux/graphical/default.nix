{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      (firefox.override { extraPolicies = { DisableTelemetry = true; DisableFirefoxStudies = true; }; })
      chromium
      (thunderbird.override { extraPolicies.DisableTelemetry = true; })
      libreoffice
      remmina
      crosspipe # PipeWire patchbay
      pdfpc # PDF Presentation
      xclip
      mesa-demos # glxinfo
      jetbrains-toolbox
    ];
  };

  fonts.fontconfig.enable = true;

  # TODO: Requires xession setup by HM?
  # home.keyboard = {
  #   options = [ "ctrl:swapcaps" ];
  # };
}
