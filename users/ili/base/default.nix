{ pkgs, lib, ... }:

{
  home = {
    stateVersion = "21.03";
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
      killall
      file
      binutils # readelf
      ripgrep
      ranger

      # Archiving
      unzip
      (p7zip.override {
        enableUnfree = true; # RAR support
      })

      # System monitoring
      htop
      nload
      cpufrequtils # cpufreq-info
      pciutils # lspci
      arp-scan
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
    bat.enable = true;
    bash = {
      enable = true;
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
      shellOptions = [ "histappend" ];
      initExtra = ''
        # Write to history file and only read new commands
        # since last read
        __HISTORY_UPDATE="history -a;history -n"
        if [ -z "$PROMPT_COMMAND" ]; then
          PROMPT_COMMAND="$__HISTORY_UPDATE"
        elif [ "$PROMPT_COMMAND" == *";" ]; then
          PROMPT_COMMAND="$PROMPT_COMMAND$__HISTORY_UPDATE;"
        else
          PROMPT_COMMAND="$PROMPT_COMMAND;$__HISTORY_UPDATE"
        fi
      '';
    };
    command-not-found.enable = true;
    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      baseIndex = 1;
      escapeTime = 0;
      terminal = "tmux-256color";
      extraConfig = ''
        set-option -sa terminal-overrides ',xterm-256color:RGB'
        set-option -sa terminal-overrides ',alacritty:RGB'
        set -g focus-events on

        set-option -g status-position bottom

        set -g status-left ' '
        set -g status-right '''

        set -g status-fg default
        set -g status-bg default

        setw -g window-status-current-format '#[underscore,bold]#I #W'
        setw -g window-status-format '#I #W'

        # Let new windows inheirt working directory of current pane
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Copy with vim-like keybindings
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X begin-selection\; send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send -X copy-selection

        # Copy text selected by dragging the mouse
        # and use mouse wheel for scrollback
        set -g mouse

        # Change color of selected text
        # This makes the last selected character more visible
        set -g mode-style "fg=#ffffff,bg=#606060"
      '';
    };
  };
}
