{ pkgs, stdenv, fetchurl, perl, coreutils, p7zip, autoPatchelfHook, alsaLib, freetype, libX11, libXext, libXcursor, libXinerama, libXrandr, jack2 }:

let
  version = "7.2.0";
  urlVersion = builtins.replaceStrings ["."] [""] version;
  htmlDownloadUrl = "https://www.modartt.com/try?file=pianoteq_linux_trial_v${urlVersion}.7z";
  archDir =
    if stdenv.system == "x86_64-linux" then "x86-64bit"
    else throw "Unsupported system: ${stdenv.system}"; # TODO: ARM
in
stdenv.mkDerivation rec {
  pname = "pianoteq";
  inherit version;

  src = fetchurl {
    url = htmlDownloadUrl;
    postFetch = ''
      dlToken="$(${perl}/bin/perl -ne '/<form action="(try\?q=.*?)"/ && print $1 . "\n"' < $out)"
      dlTokenMatches=$(${coreutils}/bin/wc -l <<< "$dlToken")
      if [ $dlTokenMatches -ne 1 ]; then
        echo "Failed to match download token. Got $dlTokenMatches matches instead of 1" >&2
        exit 1
      fi
      rm $out # Clean up HTML page since tryDownload appends to $out
      tryDownload "https://www.modartt.com/$dlToken"
    '';
    hash = "sha256-l8rwRcXstmrLbPj8KTXjf05GnPknSBTH9ja9noDs4Vw=";
  };

  nativeBuildInputs = [
    p7zip
    autoPatchelfHook
  ];

  buildInputs = [
    alsaLib
    freetype

    # LV2 version has more dynamic dependencies than standalone VST
    libX11
    stdenv.cc.cc.lib
  ];

  # Runtime dependencies of standalone VST enumerated with strace
  runtimeDependencies = [
    libX11
    libXext
    libXcursor
    libXinerama
    libXrandr
    jack2
  ];

  unpackPhase = ''
    7z x "${src}"
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/lib/lv2"
    mkdir -p "$out/lib/vst"
    cp "Pianoteq 7/${archDir}/Pianoteq 7" "$out/bin"
    ln -s "$out/bin/Pianoteq 7" "$out/bin/pianoteq"
    cp -r "Pianoteq 7/${archDir}/Pianoteq 7.lv2" "$out/lib/lv2"
    ln -s "$out/lib/lv2/Pianoteq 7.lv2/Pianoteq_7.so" "$out/lib/vst/Pianoteq 7.so"
  '';

  meta = with pkgs.lib; {
    description = "Software synthesizer featuring physically modelled pianos";
    homepage = "https://www.modartt.com/pianoteq";
    license = licenses.unfree;
    maintainers = with maintainers; [ ilian ];
    platforms = [ "x86_64-linux" ]; # TODO: ARM
  };
}

