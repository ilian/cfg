{ config, lib, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper

, alsaLib
, gtk3

, jackSupport ? true, libjack2 ? null
, pulseaudioSupport ? true, libpulseaudio ? null
, mp3Support ? true, lame ? null
, ffmpegSupport ? true, ffmpeg ? null
, vlcSupport ? true, vlc ? null
}:

assert jackSupport -> libjack2 != null;
assert pulseaudioSupport -> libpulseaudio != null;
assert mp3Support -> lame != null;
assert ffmpegSupport -> ffmpeg != null;
assert vlcSupport -> vlc != null;

let
  inherit (lib) optional getLib;

  # Dynamic loading of plugin dependencies does not adhere to rpath of
  # reaper executable that gets modified with runtimeDependencies.
  # Patching each Plugin with DT_NEEDED is cumbersome and requires
  # hardcoding of API versions of each dependency.
  # Setting the rpath of the plugin shared object files does not
  # seem to have an effect for some plugins.
  # We opt for wrapping the executable with LD_LIBRARY_PATH prefix.
  pluginDeps = optional mp3Support lame
    ++ optional ffmpegSupport ffmpeg
    ++ optional vlcSupport vlc;
  wrapCommand = if builtins.length pluginDeps == 0 then "" else ''
    wrapProgram $out/opt/REAPER/reaper \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath pluginDeps}"
  '';

in stdenv.mkDerivation rec {
  pname = "reaper";
  version = "6.20";

  src = fetchurl {
    url = "https://www.reaper.fm/files/${lib.versions.major version}.x/reaper${builtins.replaceStrings ["."] [""] version}_linux_x86_64.tar.xz";
    sha256 = "194xglhk74ks534r3d00v84s26s4yybxkhb4h8k5rqp76g0jv635";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsaLib
    
    stdenv.cc.cc.lib # reaper and libSwell need libstdc++.so.6
    gtk3
  ];

  runtimeDependencies = [
    gtk3 # libSwell needs libgdk-3.so.0
  ]
  ++ optional jackSupport libjack2
  ++ optional pulseaudioSupport libpulseaudio;

  dontBuild = true;

  installPhase = ''
    XDG_DATA_HOME="$out/share" ./install-reaper.sh \
      --install $out/opt \
      --integrate-user-desktop
    rm $out/opt/REAPER/uninstall-reaper.sh

    ${wrapCommand}

    mkdir $out/bin
    ln -s $out/opt/REAPER/reaper $out/bin/
    ln -s $out/opt/REAPER/reamote-server $out/bin/
  '';

  meta = with lib; {
    description = "Digital audio workstation";
    homepage = "https://www.reaper.fm/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ jfrankenau ilian ];
  };
}
