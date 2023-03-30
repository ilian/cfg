{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jsonnet-language-server
    nil # nix language server
    nodePackages.bash-language-server
    terraform-ls
    yaml-language-server
  ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "base16_transparent";
      editor.cursor-shape = {
        insert = "bar"; # Change cursor to a bar instead of a block
      };
      editor.lsp = {
        display-messages = true;
      };
      keys.normal = {
        G = "goto_file_end";
        ret = ["move_line_down" "goto_first_nonwhitespace"];
        ";" = "command_mode";
      };
      keys.normal.g = {
        q = ":reflow";
      };
      keys.normal.space = {
        q = ":quit";
        w = ":write";
      };
    };
  };
}
