{ pkgs, lib, ... }:

{
  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      xonsh

      # Utilities
      killall
      file
      binutils # readelf
      ripgrep
      ranger
      dig
      whois
      unzip
      p7zip # Without RAR support
      atool # Manage file archives with sane defaults
      gnupg
      sshfs
      exif
      yt-dlp
      jq
      jless
      xsv # CSV toolkit
      parallel
      crudini
      termtosvg # Record terminal as a svg animation
      ministat # Plot and calculate stats of numeric data in files
      screen # Useful for communicating with serial devices

      # System monitoring
      strace
      tcpdump
      bridge-utils
      nload
      pciutils # lspci
      usbutils
      iotop
      sysstat # iostat, sar
      arp-scan
    ];
  };

  programs = {
    bat.enable = true;
    bash = {
      enable = true;
      shellAliases = {
        "l" = "ls -al --color=auto";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
      };
      historyFileSize = 100000;
      historySize = 100000;
      # Ignore commands beggining with a space
      historyControl = [
        "ignorespace" # Do not store commands that start with space to history (useful for sensitive args)
        "ignoredups" # Do not store repeated commands multiple times to history
      ];
      # Append history list instead of overwriting on shell exit
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

        . ${pkgs.git}/share/bash-completion/completions/git-prompt.sh
        # Show branch name in shell prompt
        # Original PS1: '\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] '
        PS1='\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]$(__git_ps1 " (%s) ")\$\[\033[0m\] '

        # Create or attach to a tmux session on ssh login
        # We don't attach for nested shells (e.g. when entering a nix shell)
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]] \
           && [[ $SHLVL == 1 ]]; then
          tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
        fi
        export PATH="$PATH":$HOME/bin
      '';
    };
    command-not-found.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    htop = {
      enable = true;
      settings = {
        show_cpu_usage = true;
        detailed_cpu_time = true; # Do not count steal time towards CPU usage %
        highlight_base_name = true;
        vim_mode = true;
      };
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      baseIndex = 1;
      escapeTime = 0;
      terminal = "tmux-256color";
      # Consistent socket path for both terminal started from KDE and ssh session
      secureSocket = false;
      extraConfig = ''
        set-option -sa terminal-overrides ',xterm-256color:RGB'
        set-option -sa terminal-overrides ',alacritty:RGB'
        set -g focus-events on

        set-option -g status-position bottom

        set -g status-left ' '
        set -g status-right '''

        set -g status-style bg=default

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

        # Copy text selected by dragging the mouse and use mouse wheel for
        # scrollback
        set -g mouse

        # Change color of selected text
        # This makes the last selected character more visible
        set -g mode-style "fg=#ffffff,bg=#606060"

        # Do not update DISPLAY when attaching to tmux from an ssh session
        # which can cause the variable to be unset
        set-option -g update-environment "KRB5CCNAME SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"

        # Forward all special tmux key combinations after pressing the F5 key.
        # Changes can be reverted after pressing F5 again.
        # Useful for nested tmux sessions.
        bind-key -T root F5 \
          set prefix None \; \
          set key-table forward \; \
          set -g status-right '[Forward mode]'
        bind-key -T forward F5 \
          set -u prefix \; \
          set -u key-table \; \
          set -g status-right '''
      '';
    };
  };
}
