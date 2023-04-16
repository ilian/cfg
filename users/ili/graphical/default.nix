{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })

      firefox
      chromium
      thunderbird
      libreoffice
      remmina
      helvum # pipewire patchbay
      pianoteq
      pdfpc # PDF Presentation
      xclip
      unstable.obsidian
      blender
      mesa-demos # glxinfo
    ];
  };

  fonts.fontconfig.enable = true;

  # TODO: Requires xession setup by HM?
  home.keyboard = {
    options = [ "ctrl:swapcaps" ];
  };

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
    wezterm = {
      enable = true;
      colorSchemes = {
        # https://github.com/wez/wezterm/blob/main/assets/colors/tokyonight-storm.toml
        tokyonight-storm = {
          ansi = [
            "#1d202f"
            "#f7768e"
            "#9ece6a"
            "#e0af68"
            "#7aa2f7"
            "#bb9af7"
            "#7dcfff"
            "#a9b1d6"
          ];
          brights = [
            "#414868"
            "#f7768e"
            "#9ece6a"
            "#e0af68"
            "#7aa2f7"
            "#bb9af7"
            "#7dcfff"
            "#c0caf5"
          ];
          background = "#24283b";
          cursor_bg = "#c0caf5";
          cursor_border = "#c0caf5";
          cursor_fg = "#1d202f";
          foreground = "#c0caf5";
          selection_bg = "#364a82";
          selection_fg = "#c0caf5";
        };

        kanagawabones = {
          ansi = [
            "#1f1f28"
              "#e46a78"
              "#98bc6d"
              "#e5c283"
              "#7eb3c9"
              "#957fb8"
              "#7eb3c9"
              "#ddd8bb"
          ];
          background = "#1f1f28";
          brights = [
            "#3c3c51"
              "#ec818c"
              "#9ec967"
              "#f1c982"
              "#7bc2df"
              "#a98fd2"
              "#7bc2df"
              "#a8a48d"
          ];
          cursor_bg = "#e6e0c2";
          cursor_border = "#e6e0c2";
          cursor_fg = "#1f1f28";
          foreground = "#ddd8bb";
          selection_bg = "#49473e";
          selection_fg = "#ddd8bb";
        };
      };
      extraConfig = builtins.readFile ./wezterm.lua;
    };
    mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
      };
    };
  };
}
