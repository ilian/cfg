{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jsonnet-language-server
    marksman # Markdown language server
    nodePackages.bash-language-server
    terraform-ls
    yaml-language-server
  ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight_storm";
      editor = {
        cursor-shape.insert = "bar";
        lsp.display-messages = true;
        indent-guides.render = true;
        idle-timeout = 200;
        rulers = [80];
        statusline = {
          left = ["mode" "selections" "spinner" "file-name" "total-line-numbers"];
          right = ["diagnostics" "file-encoding" "file-line-ending" "file-type" "position-percentage" "position"];
        };
      };

      keys = let
        common = {
          "0" = "goto_line_start";
          "^" = "goto_first_nonwhitespace";
          "$" = "goto_line_end";
          G = "goto_file_end";
          ret = ["move_line_down" "goto_first_nonwhitespace"];
        };
      in {
        normal = lib.mkMerge [
          common
          {
            V = ["select_mode" "extend_to_line_bounds"];
            ";" = "command_mode";

            g.q = ":reflow";
            space.q = ":quit";
            space.w = ":write";
            space.space = "goto_last_accessed_file";
          }
        ];
        select = lib.mkMerge [
          common
          {}
        ];
      };
    };
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
  };
}
