{ pkgs, lib, ... }:

{
  imports = [
    ./vim
  ];

  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      mosh
      xonsh

      # Utilities
      coreutils
      time
      file
      binutils # readelf
      procps # watch (+ top, ps, free on Linux; macOS build is watch-only)
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
      parallel
      crudini
      termtosvg # Record terminal as a svg animation
      ministat # Plot and calculate stats of numeric data in files
      screen # Useful for communicating with serial devices

      # System monitoring
      tcpdump
      nload
      pciutils # lspci
      arp-scan
      mtr # tracepath TUI with packet loss measurement
    ] ++ lib.optionals stdenv.isDarwin (
      # The Nix rebuilds of these tools lack the private entitlements Apple
      # signs the system copies with, so they break (e.g. `ps: time: requires
      # entitlement`). Shadow them with symlinks to the entitled binaries.
      # Audit with: codesign -d --entitlements - /bin/<tool>
      map (p: lib.hiPrio (runCommandLocal "system-${baseNameOf p}" { } ''
        mkdir -p $out/bin
        ln -s ${p} $out/bin/${baseNameOf p}
      '')) [
        "/bin/ps"
        "/usr/bin/top"
      ]
    );
  };

  programs = {
    bat.enable = true;
    bash = {
      enable = true;
      shellAliases = {
        "l" = "ls -al --color=auto";
        "ll" = "ls -hl --color=auto";
        "e" = "$EDITOR";
        "g" = "git";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
      };
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

        . ${pkgs.complete-alias}/bin/complete_alias
        complete -F _complete_alias g

        # Create or attach to a tmux session on ssh login
        # We don't attach for nested shells (e.g. when entering a nix shell)
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]] \
           && [[ $SHLVL == 1 ]]; then
          tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
        fi
        export PATH="$PATH":$HOME/bin:$HOME/.local/share/go/bin:$HOME/go/bin
      '';
    };
    command-not-found.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        "*.swp"
        "*.kate-swp"
        ".direnv"
        ".venv"
        ".idea"
        ".DS_Store"
        ".codex"
        ".claude"
      ];
      includes = [
        { path = "~/work/.gitconfig"; condition = "gitdir:~/work/"; }
      ];
      settings = {
        alias = {
          c = "commit";
          co = "checkout";
          d = "diff";
          ds = "diff --staged";
          fo = "fetch origin";
          fp = "fetch -p";
          fu = "fetch upstream";
          l = "log";
          rom = "rebase origin/master";
          rum = "rebase upstream/master";
          s = "status";
        };
        user = {
          name = "ilian";
          email = "git@ilian.dev";
        };
        merge.conflictstyle = "diff3";
      };
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
      historyLimit = 50000;
      extraConfig = ''
        set-option -sa terminal-overrides ',xterm-256color:RGB'
        set-option -sa terminal-overrides ',alacritty:RGB'

        # Preserve key modifiers when forwarding input from Ghostty.
        set-option -as terminal-features ',xterm-ghostty:extkeys'
        set -g extended-keys on
        set -g extended-keys-format csi-u

        set -g focus-events on

        set-option -g status-position bottom

        set -g status-left ' '
        set -g status-right '''

        set -g status-style bg=default

        # Include the active pane's current directory basename in each tab.
        # Keep it muted and short so the tab list stays readable.
        setw -g window-status-current-format '#[underscore,bold]#I #W#[fg=colour244] (#{?#{>:#{w:#{b:pane_current_path}},10},#{=/9/…:#{b:pane_current_path}},#{b:pane_current_path}})'
        setw -g window-status-format '#I #W#[fg=colour244] (#{?#{>:#{w:#{b:pane_current_path}},10},#{=/9/…:#{b:pane_current_path}},#{b:pane_current_path}})'

        # Let new windows inheirt working directory of current pane
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Allow applications inside tmux to forward OSC 52 clipboard writes
        # to the outer terminal. The default `external` value only permits
        # clipboard writes initiated by tmux itself.
        set -s set-clipboard on

        # Copy with vim-like keybindings
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X begin-selection\; send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send -X copy-selection

        # Copy text selected by dragging the mouse and use mouse wheel for
        # scrollback
        set -g mouse on

        # If a mouse drag has not scrolled back, finish selection on release by
        # leaving copy-mode. Once scrolled up, keep copy-mode open on release so
        # tmux does not jump back to the bottom; clear the selection, then move
        # the cursor to the start of the line so it does not obscure the text.
        bind-key -T copy-mode-vi MouseDragEnd1Pane if-shell -F '#{==:#{scroll_position},0}' 'send-keys -X copy-selection-and-cancel' 'send-keys -X copy-selection-no-clear; send-keys -X clear-selection; send-keys -X start-of-line'

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
