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
    #rust-analyzer
    lf
  ];

  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    settings = {
      theme = "kanagawa";
      editor = {
        cursor-shape.insert = "bar";
        idle-timeout = 200;
        indent-guides.render = true;
        line-number = "relative";
        lsp.display-inlay-hints = true;
        lsp.display-messages = true;
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
            D = ["ensure_selections_forward" "extend_to_line_end" "delete_selection"];

            g.q = ":reflow";
            space.q = ":quit";
            space.w = ":write";
            space.space = "goto_last_accessed_file";
            space.t = [":new" ":insert-output lf -selection-path=/dev/stdout" "split_selection_on_newline" "goto_file" "goto_last_modification" "goto_last_modified_file" ":buffer-close!" ":redraw"];
          }
        ];
        select = lib.mkMerge [
          common
          {}
        ];
      };
    };
  };
}
