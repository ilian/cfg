{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    pkgs.unstable.zed-editor
    ffmpeg  # ffplay
  ];

  programs = {
    alacritty = {
      enable = true;
      settings =
        let
          alacritty-theme = pkgs.fetchFromGitHub {
            owner = "alacritty";
            repo = "alacritty-theme";
            rev = "a7c1c8b318520e28a7cb3c2e8c5c348931919080";
            hash = "sha256-qByvzkrsT8qx95o1bvnHF1ssae9JcDj/0VDOcjk5e+w=";
          };
          getTheme = themeName :
            builtins.fromTOML (builtins.readFile "${alacritty-theme}/themes/${themeName}.toml");
          theme = getTheme "kanagawa_wave";
        in theme // {
          terminal.shell.program = "tmux";
          font = let font = "Hack Nerd Font Mono"; in {
            normal      = { family = font; style = "Regular"; };
            bold        = { family = font; style = "Bold"; };
            italic      = { family = font; style = "Italic"; };
            bold_italic = { family = font; style = "Bold Italic"; };
          };
          window.option_as_alt = "Both"; # Make key combinations with ALT work on macOS
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
