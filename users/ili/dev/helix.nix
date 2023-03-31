{pkgs, ...}: let
  theme = "tokyonight_storm";
  lf-pick = pkgs.writeShellScriptBin "lf-pick" ''
    function lfp(){
      local TEMP=$(mktemp)
      ${pkgs.lf}/bin/lf -selection-path="$TEMP"
      cat "$TEMP"
      rm "$TEMP"
    }

    lfp
  '';
in {
  home.packages = with pkgs; [
    jsonnet-language-server
    marksman # Markdown language server
    nodePackages.bash-language-server
    terraform-ls
    yaml-language-server
  ];
  programs.helix = {
    enable = true;
    languages = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.alejandra}/bin/alejandra";
        formatter.args = ["-"];
        language-server.command = "${pkgs.nil}/bin/nil";
      }
      {
        name = "json";
        auto-format = true;
        language-server.command = "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
        language-server.args = ["--stdio"];
      }
    ];
    settings = {
      theme = theme;
      editor = {
        bufferline = "always";
        rulers = [80];
      };
      editor.cursor-shape = {
        insert = "bar"; # Change cursor to a bar instead of a block
      };
      editor.lsp = {
        display-messages = true;
      };
      keys.normal = {
        "0" = "goto_line_start";
        "^" = "goto_first_nonwhitespace";
        "$" = "goto_line_end";
        G = "goto_file_end";
        ret = ["move_line_down" "goto_first_nonwhitespace"];
        ";" = "command_mode";
        # Tree file picker, based on https://gist.github.com/lukepighetti/8e4a13db5bdcd68a7d83eee19051ab14
        # Broken due to broken UI after picking a file
        # "C-f" = [
        #   ":new"
        #   ":theme default"
        #   ":insert-output ${lf-pick}/bin/lf-pick"
        #   "select_all"
        #   "split_selection_on_newline"
        #   "goto_file"
        #   "goto_last_modified_file"
        #   ":buffer-close!"
        #   ":theme ${theme}"
        # ];
      };
      keys.normal.g = {
        q = ":reflow";
      };
      keys.normal.space = {
        q = ":quit";
        w = ":write";
      };
      keys.select = {
        "0" = "goto_line_start";
        "^" = "goto_first_nonwhitespace";
        "$" = "goto_line_end";
      };
    };
  };
}
