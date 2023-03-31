{pkgs, ...}: {
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
      theme = "tokyonight_storm";
      editor = {
        cursor-shape.insert = "bar";
        lsp.display-messages = true;
        idle-timeout = 200;
        bufferline = "always";
        rulers = [80];
      };
      keys.normal = {
        "0" = "goto_line_start";
        "^" = "goto_first_nonwhitespace";
        "$" = "goto_line_end";
        G = "goto_file_end";
        ret = ["move_line_down" "goto_first_nonwhitespace"];
        ";" = "command_mode";

        g.q = ":reflow";
        space.q = ":quit";
        space.w = ":write";
      };
      keys.select = {
        "0" = "goto_line_start";
        "^" = "goto_first_nonwhitespace";
        "$" = "goto_line_end";
      };
    };
  };
}
