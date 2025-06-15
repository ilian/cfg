{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })

      firefox
      chromium
      thunderbird
      slack
      libreoffice
      remmina
      helvum # pipewire patchbay
      pdfpc # PDF Presentation
      xclip
      blender
      mesa-demos # glxinfo
      ffmpeg-full # ffplay
    ];
  };

  fonts.fontconfig.enable = true;

  # TODO: Requires xession setup by HM?
  # home.keyboard = {
  #   options = [ "ctrl:swapcaps" ];
  # };

  programs = {
    alacritty = {
      enable = true;
      settings =
        let
          alacritty-theme = pkgs.fetchFromGitHub {
            owner = "eendroroy";
            repo = "alacritty-theme";
            rev = "0760a0c6129c7a51d2eb9995639b8bc6e1a3c793";
            hash = "sha256-CWRAYDG5wAGwt6v8CljxREyHAQQ+vh1M8IiyoMm7yYE=";
          };
          fromYAML = yaml:
            builtins.fromJSON (builtins.readFile (pkgs.stdenv.mkDerivation {
              name = "fromYAML";
              phases = [ "buildPhase" ];
              buildPhase = "${pkgs.yaml2json}/bin/yaml2json < ${builtins.toFile "yaml" yaml} > $out";
            }));
          getTheme = themeName :
            fromYAML (builtins.readFile "${alacritty-theme}/themes/${themeName}.yaml");
          theme = getTheme "gruvbox_dark";
        in theme // {
          shell.program = "tmux";
          colors.primary.background = "0x1d2021"; # Higher contrast
          font = let font = "Hack Nerd Font Mono"; in {
            normal      = { family = font; style = "Regular"; };
            bold        = { family = font; style = "Bold"; };
            italic      = { family = font; style = "Italic"; };
            bold_italic = { family = font; style = "Bold Italic"; };
          };
        };
    };
    foot = {
      enable = true;
      settings = {
        main = {
        };
      };
    };
    mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
      };
    };
  };
}
