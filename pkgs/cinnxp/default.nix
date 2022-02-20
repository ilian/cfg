# CinnXP themes for Cinnamon
#
# Window borders and Icons are not shown under Settings -> Themes
# Use the following commands to enable the window borders theme:
# dconf write /org/cinnamon/desktop/wm/preferences/theme "'CinnXP-Embedded'"

{ stdenv
, fetchFromGitHub
, bash
, which
, sassc
, xcursorgen
, glib
}:

stdenv.mkDerivation rec {
  pname = "cinnxp-theme";
  version = "2018-08-17";

  src = fetchFromGitHub {
    owner = "ndwarshuis";
    repo = "CinnXP";
    rev = "b24e8a68de394d65cfa6fcb6aaa577f68207908b";
    hash = "sha256-M++dOQ1qXRep1eCRnMcUXcP2u0CWu3EmXIikJ2eho2w=";
  };

  buildInputs = [
    which
    sassc
    xcursorgen
    glib # provides glib-compile-resources
  ];

  patchPhase = ''
    runHook prePatch

    substituteInPlace "./compile-theme" \
      --replace "/bin/bash" "${bash}/bin/bash"
    substituteInPlace "theme-src/common/textfiles/gtk-3.18/parse-sass.sh" \
      --replace "/bin/bash" "${bash}/bin/bash"
    substituteInPlace "theme-src/common/textfiles/cinnamon/parse-sass.sh" \
      --replace "/bin/bash" "${bash}/bin/bash"

    runHook postPatch
  '';

  buildPhase = ''
    which sassc
    ./compile-theme -a -g 20
  '';

  installPhase = ''
    cd pkg/usr/share
    find . -type f -exec install -Dm 755 "{}" "$out/share/{}" \;
  '';
}
