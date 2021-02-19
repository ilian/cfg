{ pkgs, lib, ... }:

{
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  environment.systemPackages = with pkgs; [
    steam
    steam-run
  ];

  networking.firewall = lib.mkMerge [
    {
      # Remote play
      allowedTCPPorts = [ 27036 ];
      allowedUDPPortRanges = [ { from = 27031; to = 27036; } ];
    }
    {
      # Dedicated servers
      allowedTCPPorts = [ 27015 ]; # SRCDS Rcon port
      allowedUDPPorts = [ 27015 ]; # Gameplay traffic
    }
  ];

}
